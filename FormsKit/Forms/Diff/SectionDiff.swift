import UIKit
import FlexibleDiff

struct SectionDiff<SectionId: Hashable, RowId: Hashable> {
    private let oldSections: [Section<SectionId, RowId>]
    private let newSections: [Section<SectionId, RowId>]

    init(oldSections: [Section<SectionId, RowId>], newSections: [Section<SectionId, RowId>]) {
        self.oldSections = oldSections
        self.newSections = newSections
    }

    func apply(to tableView: UITableView) {
        let diff = SectionedChangeset(previous: oldSections,
                                      current: newSections,
                                      sectionIdentifier: { (section: Section<SectionId, RowId>) -> SectionId in
                                          return section.id
                                      },
                                      areSectionsEqual: { (section1: Section<SectionId, RowId>, section2: Section<SectionId, RowId>) -> Bool in
                                          return section1.isEqualTo(section2)
                                      },
                                      elementIdentifier: { (row: Node<RowId>) -> RowId in
                                          return row.id
                                      },
                                      areElementsEqual: { (row1: Node<RowId>, row2: Node<RowId>) -> Bool in
                                          return row1.isEqual(to: row2)
                                      })
        apply(diff: diff, to: tableView)
    }

    private func apply(diff: SectionedChangeset, to tableView: UITableView) {
        tableView.beginUpdates()
        for section in diff.sections.mutations {
            if let headerView = tableView.headerView(forSection: section) {
                newSections[section].updateHeader(view: headerView)
            }
            if let footerView = tableView.footerView(forSection: section) {
                newSections[section].updateFooter(view: footerView)
            }
        }
        tableView.insertSections(diff.sections.inserts, with: .fade)
        tableView.deleteSections(diff.sections.removals, with: .fade)
        apply(sectionMutations: diff.mutatedSections, to: tableView, with: .fade)
        tableView.moveSections(diff.sections.moves)
        tableView.endUpdates()
    }

    private func apply(sectionMutations: [SectionedChangeset.MutatedSection],
                       to tableView: UITableView,
                       with animation: UITableViewRowAnimation) {
        for sectionMutation in sectionMutations {
            tableView.deleteRows(at: sectionMutation.deletedIndexPaths, with: animation)
            tableView.insertRows(at: sectionMutation.insertedIndexPaths, with: animation)
            tableView.perform(moves: sectionMutation.movedIndexPaths)
            [sectionMutation.changeset.moves.lazy
                .flatMap { $0.isMutated ? ($0.source, $0.destination) : nil },
                sectionMutation.changeset.mutations.lazy.map { ($0, $0) }]
                .joined()
                .forEach { source, destination in
                    guard let cell = tableView.cellForRow(at: [sectionMutation.source, source]) else { return }
                    newSections[sectionMutation.destination][destination].render(in: cell)
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
