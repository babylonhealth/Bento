import FlexibleDiff

/// The adapter store which carries the component tree, and also cached sizing information if enabled.
///
/// The adapter computes sizing information lazily upon request, but it adjusts spaces and performs cache invalidation
/// every time a diff is applied.
///
/// - important: While the use-as-you-go Bento uses the adapter, the size caching capability should only be enabled in
///              `SizeCachingTableView` and `SizeCachingCollectionView`, since there are specific messages that Bento
///              need to intercept for size caching to function as expected.
struct AdapterStore<SectionID: Hashable, ItemID: Hashable> {
    private(set) var sections: [Section<SectionID, ItemID>] = []

    var sizingStrategy: SizingStrategy = .fillHorizontally

    var cachesSizeInformation: Bool = false {
        didSet {
            if cachesSizeInformation && info.isEmpty {
                invalidateCachedInfo()
            } else {
                info = []
            }
        }
    }

    var boundSize: CGSize = .unknown {
        didSet {
            if cachesSizeInformation && oldValue != boundSize {
                invalidateCachedInfo()
            }
        }
    }

    var layoutMargins: UIEdgeInsets = .zero {
        didSet {
            if cachesSizeInformation && oldValue != layoutMargins {
                invalidateCachedInfo()
            }
        }
    }

    /// All cached information. If it is empty, it means either there is no item, or the cache structure hasn't been
    /// setup yet.
    private var info: [SectionInfo] = []

    init() {}

    mutating func size(for supplement: Supplement, inSection section: Int, allowEstimation: Bool = false) -> SupplementSizingResult {
        guard let component = sections[section].supplements[supplement] else { return .doesNotExist }
        guard cachesSizeInformation else { return .noCachedResult }

        let knownSize = info[section].supplements[supplement, default: .invalidated(nil)]
            .size(allowEstimation: allowEstimation)

        if let knownSize = knownSize {
            return .size(knownSize)
        } else if allowEstimation {
            return .noCachedResult
        } else {
            let size = sizingStrategy.size(
                of: component,
                boundSize: boundSize,
                layoutMargins: layoutMargins
            )

            info[section].supplements[supplement] = .sized(size)
            return .size(size)
        }
    }

    mutating func size(forItemAt indexPath: IndexPath, allowEstimation: Bool = false) -> CGSize? {
        guard cachesSizeInformation else { return nil }

        let knownSize = info[indexPath.section].items[indexPath.item]
            .size(allowEstimation: allowEstimation)

        if let knownSize = knownSize {
            return knownSize
        } else if allowEstimation {
            return nil
        } else {
            let size = sizingStrategy.size(
                of: sections[indexPath.section].items[indexPath.item].component,
                boundSize: boundSize,
                layoutMargins: layoutMargins
            )

            info[indexPath.section].items[indexPath.item] = .sized(size)
            return size
        }
    }

    mutating func removeItem(at indexPath: IndexPath) {
        sections[indexPath.section].items.remove(at: indexPath.row)
    }

    mutating func update(with sections: [Section<SectionID, ItemID>], knownSupplements: Set<Supplement>, changeset: SectionedChangeset? = nil) {
        self.sections = sections

        guard cachesSizeInformation else { return }

        guard let changeset = changeset else {
            resetCachedInfo()
            return
        }

        info.applyIgnoringMutation(
            changeset.sections,
            newElement: SectionInfo(),
            whenInserted: { info, index in
                info.items = Array(repeating: .invalidated(nil), count: sections[index].items.count)
            }
        )

        // Apply changeset to the old section info for all mutated sections.
        for mutatedSection in changeset.mutatedSections {
            let index = mutatedSection.destination

            // NOTE: When layout equivalence is implemented, we need to update this to avoid not invalidating entries
            //       when layout is declared not to have changed.
            info[index].supplements = info[index].supplements.mapValues { $0.with { $0.invalidate() } }

            info[index].apply(mutatedSection.changeset)
        }
    }

    mutating func invalidateCachedInfo() {
        for sectionIndex in info.indices {
            info[sectionIndex].supplements = info[sectionIndex].supplements
                .mapValues { $0.with { $0.invalidate() } }

            for itemIndex in info[sectionIndex].items.indices {
                info[sectionIndex].items[itemIndex].invalidate()
            }
        }
    }

    mutating func resetCachedInfo() {
        info = Array(repeating: SectionInfo(), count: sections.count)
        for index in info.indices {
            info[index].items = Array(repeating: .invalidated(nil), count: sections[index].items.count)
        }
    }
}

enum SupplementSizingResult: Equatable {
    case doesNotExist
    case noCachedResult
    case size(CGSize)
}

enum SizingStrategy {
    case fillHorizontally
    case fillVertically
    case compressed

    func size(of component: AnyRenderable, boundSize: CGSize, layoutMargins: UIEdgeInsets) -> CGSize {
        switch self {
        case .fillHorizontally:
            return component.sizeBoundTo(width: boundSize.width, inheritedMargins: layoutMargins)
        case .fillVertically:
            return component.sizeBoundTo(height: boundSize.height, inheritedMargins: layoutMargins)
        case .compressed:
            return component.sizeBoundTo(size: UIView.layoutFittingCompressedSize, inheritedMargins: layoutMargins)
        }
    }
}

private struct SectionInfo {
    var supplements: [Supplement: Item] = [:]
    var items: [Item] = []

    init() {}

    mutating func apply(_ changeset: Changeset) {
        items.applyIgnoringMutation(changeset, newElement: .invalidated(nil), whenInserted: { _, _ in })

        for index in changeset.mutations {
            items[index].invalidate()
        }

        for move in changeset.moves where move.isMutated {
            items[move.destination].invalidate()
        }
    }
}

internal enum Item: With {
    case sized(CGSize)
    case invalidated(CGSize?)

    func size(allowEstimation: Bool) -> CGSize? {
        switch (allowEstimation, self) {
        case let (_, .sized(size)):
            return size
        case let (true, .invalidated(size?)):
            return size
        case (true, .invalidated(nil)), (false, .invalidated):
            return nil
        }
    }

    mutating func invalidate() {
        switch self {
        case let .sized(size):
            self = .invalidated(size)
        case .invalidated:
            break
        }
    }
}

extension CGSize {
    /// A sentinel size representing unknown size. This is not known to be generated by Auto Layout, and the logical
    /// size is either zero or of positive decimals.
    fileprivate static var unknown: CGSize {
        return CGSize(width: -.infinity, height: -.infinity)
    }
}

extension Array {
    mutating func applyIgnoringMutation(_ changeset: Changeset, newElement: Element, whenInserted: (inout Element, _ index: Index) -> Void) {
        let old = self

        let allRemovals = changeset.removals
            .union(IndexSet(changeset.moves.lazy.map { $0.source }))
        let allInsertions = changeset.inserts
            .union(IndexSet(changeset.moves.lazy.map { $0.destination }))

        // Remove all entries for removed sections, and moved sections at their original position.
        for range in allRemovals.rangeView.reversed() {
            removeSubrange(range)
        }

        // Create all entries for newly inserted sections, and moved sections at their new position.
        for range in allInsertions.rangeView {
            insert(contentsOf: repeatElement(newElement, count: range.count), at: range.lowerBound)

            for index in range {
                whenInserted(&self[index], index)
            }
        }

        // Copy over the old section info for moved sections.
        for move in changeset.moves {
            self[move.destination] = old[move.source]
        }
    }
}
