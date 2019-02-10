import UIKit
import FlexibleDiff

struct TableViewSectionDiff<SectionId: Hashable, RowId: Hashable> {
    private let oldSections: [Section<SectionId, RowId>]
    private let newSections: [Section<SectionId, RowId>]
    private let animation: TableViewAnimation

    init(oldSections: [Section<SectionId, RowId>],
         newSections: [Section<SectionId, RowId>],
         animation: TableViewAnimation) {
        self.oldSections = oldSections
        self.newSections = newSections
        self.animation = animation
    }

    func apply(to tableView: UITableView, updateAdapter: @escaping () -> Void) {
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

        // NOTE: While UITableView has no documented requirement of data sources only being updated within the `update`
        //       block, unlike UICollectionView, we do the same thing here for the sake of consistency.

        if #available(iOS 11, *) {
            tableView.performBatchUpdates(
                {
                    updateAdapter()
                    self.apply(diff: diff, to: tableView)
                },
                completion: nil
            )
        } else {
            tableView.beginUpdates()
            updateAdapter()
            apply(diff: diff, to: tableView)
            tableView.endUpdates()
        }
    }

    private func apply(diff: SectionedChangeset, to tableView: UITableView) {
        let visibleSections = tableView.visibleSections

        for (source, destination) in diff.sections.positionsOfMutations(amongVisible: visibleSections) {
            if let headerView = tableView.headerView(forSection: source) {
               let component = newSections[destination].supplements[.header]
                (headerView as? BentoReusableView)?.bind(component)
            }

            if let footerView = tableView.footerView(forSection: source) {
               let component = newSections[destination].supplements[.footer]
                (footerView as? BentoReusableView)?.bind(component)
            }
        }

        tableView.insertSections(diff.sections.inserts, with: animation.sectionInsertion)
        tableView.deleteSections(diff.sections.removals, with: animation.sectionDeletion)
        tableView.moveSections(diff.sections.moves, animation: animation)
        apply(sectionMutations: diff.mutatedSections, to: tableView, with: animation)
    }

    private func apply(sectionMutations: [SectionedChangeset.MutatedSection],
                       to tableView: UITableView,
                       with animation: TableViewAnimation) {
        let visibleIndexPaths = tableView.indexPathsForVisibleRows ?? []

        for sectionMutation in sectionMutations {
            tableView.deleteRows(at: sectionMutation.deletedIndexPaths, with: animation.rowDeletion)
            tableView.insertRows(at: sectionMutation.insertedIndexPaths, with: animation.rowInsertion)
            tableView.perform(moves: sectionMutation.movedIndexPaths)

            let visibleRows = Set(
                visibleIndexPaths.lazy
                    .filter { $0.section == sectionMutation.source }
                    .map { $0.item }
            )

            for (source, destination) in sectionMutation.changeset.positionsOfMutations(amongVisible: visibleRows) {
                if let cell = tableView.cellForRow(at: IndexPath(item: source, section: sectionMutation.source)) as? BentoReusableView {
                   let node = newSections[sectionMutation.destination].items[destination]
                    cell.bind(node.component)
                }
            }
        }
    }
}

extension SectionedChangeset.MutatedSection {
    var deletedIndexPaths: [IndexPath] {
        return changeset.removals.map { IndexPath(row: $0, section: source) }
    }

    var insertedIndexPaths: [IndexPath] {
        return changeset.inserts.map { IndexPath(row: $0, section: destination) }
    }

    var movedIndexPaths: [UITableView.Move] {
        return changeset.moves.map {
            let source = IndexPath(row: $0.source, section: self.source)
            let destination = IndexPath(row: $0.destination, section: self.destination)

            return UITableView.Move(source: source, destination: destination)
        }
    }
}

extension Changeset {
    func deletedIndexPaths(for section: Int) -> [IndexPath] {
        return removals.map { IndexPath(row: $0, section: section) }
    }
}

extension UITableView {
    struct Move {
        let source: IndexPath
        let destination: IndexPath
    }

    func moveSections(_ moves: [Changeset.Move], animation: TableViewAnimation) {
        deleteSections(IndexSet(moves.map { $0.source }), with: animation.sectionDeletion)
        insertSections(IndexSet(moves.map { $0.destination }), with: animation.sectionInsertion)
    }

    func perform(moves: [Move]) {
        for move in moves {
            moveRow(at: move.source, to: move.destination)
        }
    }
}
