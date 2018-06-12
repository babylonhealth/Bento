import FlexibleDiff
import UIKit

struct CollectionViewSectionDiff<SectionId: Hashable, RowId: Hashable> {
    private let oldSections: [Section<SectionId, RowId>]
    private let newSections: [Section<SectionId, RowId>]

    init(oldSections: [Section<SectionId, RowId>],
         newSections: [Section<SectionId, RowId>]) {
        self.oldSections = oldSections
        self.newSections = newSections
    }

    func apply(to collectionView: UICollectionView, completion: (() -> Void)? = nil) {
        let diff = SectionedChangeset(previous: oldSections,
                                      current: newSections,
                                      sectionIdentifier: { $0.id },
                                      areMetadataEqual: Section.hasEqualMetadata,
                                      items: { $0.rows },
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
        for (item, section) in diff.sections.mutations.enumerated() {
            if let headerView = collectionView.supplementaryView(
                forElementKind: UICollectionElementKindSectionHeader.description,
                at: IndexPath(row: item, section: section)
                ),
                let node = newSections[section].header {
                update(view: headerView, with: node)
            }
            if let footerView = collectionView.supplementaryView(
                forElementKind: UICollectionElementKindSectionFooter.description,
                at: IndexPath(row: item, section: section)
                ),
                let node = newSections[section].footer {
                update(view: footerView, with: node)
            }
        }

        collectionView.insertSections(diff.sections.inserts)
        collectionView.deleteSections(diff.sections.removals)
        collectionView.apply(sectionMutations: diff.mutatedSections, newSections: newSections)
        collectionView.moveSections(diff.sections.moves)
    }

    private func update(view: UIView, with node: AnyRenderable) {
        guard let headerFooterView = view as? CollectionViewSupplementaryView,
            let containedView = headerFooterView.containedView else { return }
        node.render(in: containedView)
    }

    private func update(cell: UICollectionViewCell, with node: Node<RowId>) {
        guard let cell = cell as? CollectionViewContainerCell,
            let contentView = cell.containedView else { return }
        node.component.render(in: contentView)
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

    func apply<SectionId, RowId>(sectionMutations: [SectionedChangeset.MutatedSection],
                                 newSections: [Section<SectionId, RowId>]) {
        for sectionMutation in sectionMutations {
            let sectionChanges = [
                sectionMutation.changeset.moves.flatMap { $0.isMutated ? ($0.source, $0.destination) : nil },
                sectionMutation.changeset.mutations.lazy.map { ($0, $0) }
            ].joined()

            deleteItems(at: sectionMutation.deletedIndexPaths)
            insertItems(at: sectionMutation.insertedIndexPaths)
            perform(moves: sectionMutation.movedCollectionIndexPaths)
            sectionChanges
                .forEach { source, destination in
                    guard let cell = cellForItem(at: [sectionMutation.source, source]) as? CollectionViewContainerCell,
                        let contentView = cell.containedView else { return }
                    newSections[sectionMutation.destination]
                        .rows[destination]
                        .component
                        .render(in: contentView)
                }
        }
    }
}
