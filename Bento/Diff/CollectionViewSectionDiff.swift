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
        for supplement in supplements {
            let elementKind = supplement.elementKind

            let groups = Dictionary(
                grouping: collectionView.indexPathsForVisibleSupplementaryElements(ofKind: elementKind),
                by: { $0.section }
            )

            for (source, destination) in diff.sections.mutationIndexPairs {
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

    func apply<SectionID, ItemID>(
        sectionMutations: [SectionedChangeset.MutatedSection],
        newSections: [Section<SectionID, ItemID>]
    ) {
        for sectionMutation in sectionMutations {
            deleteItems(at: sectionMutation.deletedIndexPaths)
            insertItems(at: sectionMutation.insertedIndexPaths)
            perform(moves: sectionMutation.movedCollectionIndexPaths)

            for (source, destination) in sectionMutation.changeset.mutationIndexPairs {
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
