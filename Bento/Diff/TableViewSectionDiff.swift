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

    func apply(to tableView: UITableView) {
        // NOTE: Item equivalence is not considered during the diff to speed up
        //       the process, since the only place needing this piece of
        //       knowledge is updating visible items at pre-insertion indices,
        //       and we can defer the comparison till that point.
        let diff = SectionedChangeset(previous: oldSections,
                                      current: newSections,
                                      sectionIdentifier: { $0.id },
                                      areMetadataEqual: Section.hasEqualMetadata,
                                      items: { $0.items },
                                      itemIdentifier: { $0.id },
                                      areItemsEqual: { _, _ in true })
        apply(diff: diff, to: tableView)
    }

    private func apply(diff: SectionedChangeset, to tableView: UITableView) {
        tableView.beginUpdates()
        for (source, destination) in diff.sections.mutationIndexPairs {
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
        apply(sectionMutations: diff.mutatedSections, to: tableView, visibleIndexPaths: tableView.indexPathsForVisibleRows ?? [], with: animation)
        tableView.endUpdates()
    }

    private func apply(sectionMutations: [SectionedChangeset.MutatedSection],
                       to tableView: UITableView,
                       visibleIndexPaths: [IndexPath],
                       with animation: TableViewAnimation) {
        for sectionMutation in sectionMutations {
            tableView.deleteRows(at: sectionMutation.deletedIndexPaths, with: animation.rowDeletion)
            tableView.insertRows(at: sectionMutation.insertedIndexPaths, with: animation.rowInsertion)
            tableView.perform(moves: sectionMutation.movedIndexPaths)

            for indexPath in visibleIndexPaths where indexPath.section == sectionMutation.source && !sectionMutation.changeset.removals.contains(indexPath.row) {
                let component: AnyRenderable

                if let destination = sectionMutation.changeset.moves.first(where: { $0.source == indexPath.row })?.destination {
                    component = newSections[indexPath.section].items[destination].component
                } else {
                    component = newSections[indexPath.section].items[indexPath.row].component
                }

                let cell = tableView.visibleCell(at: indexPath)
                cell?.bind(component)
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
