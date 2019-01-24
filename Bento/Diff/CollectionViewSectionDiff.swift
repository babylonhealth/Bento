import FlexibleDiff
import UIKit

struct CollectionViewSectionDiff<SectionID: Hashable, ItemID: Hashable> {
    private let oldSections: [Section<SectionID, ItemID>]
    private let newSections: [Section<SectionID, ItemID>]
    private let supplements: Set<Supplement>

    init(oldSections: [Section<SectionID, ItemID>],
         newSections: [Section<SectionID, ItemID>],
         knownSupplements: Set<Supplement>) {
        self.oldSections = oldSections
        self.newSections = newSections
        supplements = knownSupplements
    }

    func apply(to collectionView: UICollectionView, completion: (() -> Void)? = nil) {
        /// Since we are going to always rebind visible components, there is no point to evaluate
        /// component equation. However, we still force all instances of components to be treated as
        /// unequal, so as to preserve all positional information for in-place updates to visible cells.
        let diff = SectionedChangeset(previous: oldSections,
                                      current: newSections,
                                      sectionIdentifier: { $0.id },
                                      areMetadataEqual: const(false),
                                      items: { $0.items },
                                      itemIdentifier: { $0.id },
                                      areItemsEqual: const(false))
        apply(diff: diff, to: collectionView, completion: completion)
    }

    func apply(to collectionView: UICollectionView, with layout: UICollectionViewLayout) {
        let diff = SectionedChangeset(previous: oldSections,
                                      current: newSections,
                                      sectionIdentifier: { $0.id },
                                      areMetadataEqual: const(false),
                                      items: { $0.items },
                                      itemIdentifier: { $0.id },
                                      areItemsEqual: const(false))

        collectionView.performBatchUpdates({
            collectionView.setCollectionViewLayout(layout, animated: true)
            self.performBatchUpdates(with: diff, for: collectionView)
        }, completion: nil)
    }

    private func apply(diff: SectionedChangeset, to collectionView: UICollectionView, completion: (() -> Void)?) {
        collectionView.performBatchUpdates({
            self.performBatchUpdates(with: diff, for: collectionView)
        }, completion: { _ in completion?() })
    }

    private func performBatchUpdates(with diff: SectionedChangeset, for collectionView: UICollectionView) {
        for supplement in supplements {
            let elementKind = supplement.elementKind

            let groups = Dictionary(grouping: collectionView.indexPathsForVisibleSupplementaryElements(ofKind: elementKind)) { $0.section }

            for (source, destination) in diff.sections.positionsOfMutations(amongVisible: groups.keys) {
                if let indexPaths = groups[source] {
                    for indexPath in indexPaths {
                        let view = collectionView.supplementaryView(forElementKind: elementKind, at: indexPath)
                        let component = newSections[destination].supplements[supplement]
                        (view as? BentoReusableView)?.bind(component)
                    }
                }
            }
        }

        collectionView.insertSections(diff.sections.inserts)
        collectionView.deleteSections(diff.sections.removals)
        collectionView.apply(sectionMutations: diff.mutatedSections, newSections: newSections)
        collectionView.moveSections(diff.sections.moves)
    }
}

extension SectionedChangeset.MutatedSection {
    var movedCollectionIndexPaths: [UICollectionView.Move] {
        return changeset.moves.map {
            let source = IndexPath(row: $0.source, section: self.source)
            let destination = IndexPath(row: $0.destination, section: self.source)

            return UICollectionView.Move(source: source, destination: destination)
        }
    }
}

extension UICollectionView {
    struct Move {
        let source: IndexPath
        let destination: IndexPath
    }

    func moveSections(_ moves: [Changeset.Move]) {
        for move in moves {
            moveSection(move.source, toSection: move.destination)
        }
    }

    func perform(moves: [Move]) {
        for move in moves {
            moveItem(at: move.source, to: move.destination)
        }
    }

    func apply<SectionID, ItemID>(sectionMutations: [SectionedChangeset.MutatedSection],
                                  newSections: [Section<SectionID, ItemID>]) {
        for sectionMutation in sectionMutations {
            deleteItems(at: sectionMutation.deletedIndexPaths)
            insertItems(at: sectionMutation.insertedIndexPaths)
            perform(moves: sectionMutation.movedCollectionIndexPaths)
            
            let visibleItems = Set(
                indexPathsForVisibleItems
                    .compactMap { $0.section == sectionMutation.source ? $0.row : nil }
            )

            for (source, destination) in sectionMutation.changeset.positionsOfMutations(amongVisible: visibleItems) {
                if let cell = cellForItem(at: [sectionMutation.source, source]) as? CollectionViewContainerCell {
                    let component = newSections[sectionMutation.destination]
                        .items[destination]
                        .component
                    cell.bind(component)
                }
            }
        }
    }
}
