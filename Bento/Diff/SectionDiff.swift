import FlexibleDiff
import UIKit

struct SectionDiff<CollectionView: BentoCollectionView, SectionID: Hashable, ItemID: Hashable> {
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

    func apply(to collectionView: CollectionView, completion: ((Bool) -> Void)? = nil) {
        let diff = SectionedChangeset(previous: oldSections,
                                      current: newSections,
                                      sectionIdentifier: { $0.id },
                                      areMetadataEqual: Section.hasEqualMetadata,
                                      items: { $0.items },
                                      itemIdentifier: { $0.id },
                                      areItemsEqual: ==)
        apply(diff: diff, to: collectionView, completion: completion)
    }

    private func apply(diff: SectionedChangeset, to collectionView: CollectionView, completion: ((Bool) -> Void)?) {
        collectionView.batchUpdate(
            { self.performBatchUpdates(with: diff, for: collectionView) },
            completion: completion
        )
    }

    private func performBatchUpdates(with diff: SectionedChangeset, for collectionView: CollectionView) {
        collectionView.updateSupplements(supplements, diffMutations: diff.sections.mutationIndexPairs, newSections: newSections)
        collectionView.insertSections(diff.sections.inserts)
        collectionView.deleteSections(diff.sections.removals)
        collectionView.apply(sectionMutations: diff.mutatedSections, newSections: newSections)
        collectionView.moveSections(diff.sections.moves)
    }
}

fileprivate extension BentoCollectionView {
    func moveSections(_ moves: [Changeset.Move]) {
        // NOTE: `moveSections` does not behave correctly when there are overlapping item-level
        //       move operations.
        deleteSections(IndexSet(moves.map { $0.source }))
        insertSections(IndexSet(moves.map { $0.destination }))
    }

    func moveItems(_ moves: [Changeset.Move], oldSectionIndex: Int, newSectionIndex: Int) {
        for move in moves {
            moveItem(at: IndexPath(item: move.source, section: oldSectionIndex),
                     to: IndexPath(item: move.destination, section: newSectionIndex))
        }
    }

    func apply<SectionID, ItemID>(
        sectionMutations: [SectionedChangeset.MutatedSection],
        newSections: [Section<SectionID, ItemID>]
    ) {
        for sectionMutation in sectionMutations {
            deleteItems(at: sectionMutation.changeset.removals
                .map { IndexPath(item: $0, section: sectionMutation.source) })
            insertItems(at: sectionMutation.changeset.inserts
                .map { IndexPath(item: $0, section: sectionMutation.destination) })
            moveItems(sectionMutation.changeset.moves,
                      oldSectionIndex: sectionMutation.source,
                      newSectionIndex: sectionMutation.destination)

            for (source, destination) in sectionMutation.changeset.mutationIndexPairs {
                if let cell = visibleCell(at: [sectionMutation.source, source]) as? BentoReusableView {
                    let component = newSections[sectionMutation.destination]
                        .items[destination]
                        .component
                    cell.bind(component)
                }
            }
        }
    }
}
