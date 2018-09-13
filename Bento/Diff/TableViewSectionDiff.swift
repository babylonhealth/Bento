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
        let diff = SectionedChangeset(previous: oldSections,
                                      current: newSections,
                                      sectionIdentifier: { $0.id },
                                      areMetadataEqual: Section.hasEqualMetadata,
                                      items: { $0.items },
                                      itemIdentifier: { $0.id },
                                      areItemsEqual: ==)
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
        apply(sectionMutations: diff.mutatedSections, to: tableView, with: animation)
        tableView.moveSections(diff.sections.moves)
        tableView.endUpdates()
    }

    private func apply(sectionMutations: [SectionedChangeset.MutatedSection],
                       to tableView: UITableView,
                       with animation: TableViewAnimation) {
        for sectionMutation in sectionMutations {
            tableView.deleteRows(at: sectionMutation.deletedIndexPaths, with: animation.rowDeletion)
            tableView.insertRows(at: sectionMutation.insertedIndexPaths, with: animation.rowInsertion)
            tableView.perform(moves: sectionMutation.movedIndexPaths)

            for (source, destination) in sectionMutation.changeset.mutationIndexPairs {
                if let cell = tableView.cellForRow(at: [sectionMutation.source, source]) as? BentoReusableView {
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
            let destination = IndexPath(row: $0.destination, section: self.source)

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

    func moveSections(_ moves: [Changeset.Move]) {
        for move in moves {
            moveSection(move.source, toSection: move.destination)
        }
    }

    func perform(moves: [Move]) {
        for move in moves {
            moveRow(at: move.source, to: move.destination)
        }
    }
}
