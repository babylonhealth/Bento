import UIKit
import FlexibleDiff

final class SectionedFormAdapter<SectionId: Hashable, RowId: Hashable>
    : NSObject,
      UITableViewDataSource,
      UITableViewDelegate {
    private var sections: [Section<SectionId, RowId>] = []
    private weak var tableView: UITableView?

    public init(with tableView: UITableView) {
        self.sections = []
        self.tableView = tableView
        super.init()
        tableView.dataSource = self
        tableView.delegate = self
    }

    public func update(sections: [Section<SectionId, RowId>]) {
        guard let tableView = tableView else {
            return
        }
        let diff = SectionedChangeset(previous: self.sections,
                                      current: sections,
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
        self.sections = sections
        tableView.beginUpdates()
        tableView.insertSections(diff.sections.inserts, with: .fade)
        tableView.deleteSections(diff.sections.removals, with: .fade)
        tableView.reloadSections(diff.sections.mutations, with: .fade)
        diff.mutatedSections.forEach { key, value in
            let deletedRows: [IndexPath] = value.changeset.removals.map { [key, $0] }
            let insertedRows: [IndexPath] = value.changeset.inserts.map { [key, $0] }
            tableView.deleteRows(at: deletedRows, with: .fade)
            tableView.insertRows(at: insertedRows, with: .fade)
            [value.changeset.moves.lazy
                .flatMap { $0.isMutated ? ($0.source, $0.destination) : nil },
                value.changeset.mutations.lazy.map { ($0, $0) }]
                .joined()
                .forEach { source, destination in
                    let indexPath: IndexPath = [value.source, source]
                    self.sections[value.source].updateNode(in: tableView, at: indexPath)
                }
        }
        tableView.endUpdates()
    }

    public func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].rowsCount
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return sections[indexPath.section].renderCell(in: tableView, at: indexPath.row)
    }

    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return sections[section].renderHeader(in: tableView)
    }

    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return sections[section].renderFooter(in: tableView)
    }
}
