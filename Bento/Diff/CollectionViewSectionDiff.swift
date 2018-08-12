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
        self.supplements = knownSupplements
    }

    func apply(to collectionView: UICollectionView, completion: (() -> Void)? = nil) {
        let diff = SectionedChangeset(previous: oldSections,
                                      current: newSections,
                                      sectionIdentifier: { $0.id },
                                      areMetadataEqual: Section.hasEqualMetadata,
                                      items: { $0.items },
                                      itemIdentifier: { $0.id },
                                      areItemsEqual: ==)
        apply(diff: diff, to: collectionView, completion: completion)
    }

    private func apply(diff: SectionedChangeset, to collectionView: UICollectionView, completion: (() -> Void)?) {
        collectionView.performBatchUpdates({
            self.performBatchUpdates(with: diff, for: collectionView)
        }, completion: { _ in completion?() })
    }

    private func performBatchUpdates(with diff: SectionedChangeset, for collectionView: UICollectionView) {
        for section in diff.sections.mutations {
            for supplement in supplements {
                let view = collectionView.supplementaryView(
                    forElementKind: supplement.elementKind,
                    at: IndexPath(index: section)
                )

                let component = newSections[section].supplements[supplement]
                (view as? BentoReusableView)?.bind(component)
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

    func apply<SectionID, ItemID>(
        sectionMutations: [SectionedChangeset.MutatedSection],
        newSections: [Section<SectionID, ItemID>]
    ) {
        for sectionMutation in sectionMutations {
            let sectionChanges = [
                sectionMutation.changeset.moves.compactMap { $0.isMutated ? ($0.source, $0.destination) : nil },
                sectionMutation.changeset.mutations.lazy.map { ($0, $0) }
            ].joined()

            deleteItems(at: sectionMutation.deletedIndexPaths)
            insertItems(at: sectionMutation.insertedIndexPaths)
            perform(moves: sectionMutation.movedCollectionIndexPaths)
            sectionChanges
                .forEach { source, destination in
                    guard let cell = cellForItem(at: [sectionMutation.source, source]) as? CollectionViewContainerCell
                        else { return }
                    let component = newSections[sectionMutation.destination]
                        .items[destination]
                        .component
                    cell.bind(component)
                }
        }
    }
}
