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
                                      items: { $0.rows },
                                      itemIdentifier: { $0.id },
                                      areItemsEqual: ==)
        apply(diff: diff, to: tableView)
    }

    private func apply(diff: SectionedChangeset, to tableView: UITableView) {
        tableView.beginUpdates()
        for section in diff.sections.mutations {
            if let headerView = tableView.headerView(forSection: section),
                let node = newSections[section].header {
                update(view: headerView, with: node)
            }
            if let footerView = tableView.footerView(forSection: section),
                let node = newSections[section].footer {
                update(view: footerView, with: node)
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
            [sectionMutation.changeset.moves.lazy
                .compactMap { $0.isMutated ? ($0.source, $0.destination) : nil },
             sectionMutation.changeset.mutations.lazy.map { ($0, $0) }]
                .joined()
                .forEach { source, destination in
                    guard let cell = tableView.cellForRow(at: [sectionMutation.source, source]) else { return }
                    update(cell: cell, with: newSections[sectionMutation.destination].rows[destination])
            }
        }
    }

    private func update(view: UIView, with node: AnyRenderable) {
        guard let headerFooterView = view as? TableViewHeaderFooterView,
            let containedView = headerFooterView.containedView else { return }
        node.render(in: containedView)
    }

    private func update(cell: UITableViewCell, with node: Node<RowId>) {
        guard let cell = cell as? TableViewCell,
            let contentView = cell.containedView else { return }
        node.component.render(in: contentView)
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
