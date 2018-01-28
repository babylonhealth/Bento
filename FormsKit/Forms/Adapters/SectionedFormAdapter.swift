import UIKit
import FlexibleDiff

public final class SectionedFormAdapter<SectionId: Hashable, RowId: Hashable>
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
                                      sectionIdentifier: { element in
                                          return element.id
                                      },
                                      areSectionsEqual: { (v, v1) in
                                          return v.id == v1.id
                                      },
                                      elementIdentifier: { element in
                                          return element.id
                                      },
                                      areElementsEqual: { (v, v1) in
                                          return v.component === v1.component
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
                    let idexPath: IndexPath = [value.source, source]
                    guard
                        let cell = tableView.cellForRow(at: idexPath) as? TableViewCell,
                        let componentView = cell.containedView
                        else { fatalError() }
                    self.sections[value.source].render(view: componentView, at: source)
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
        return sections[indexPath.section].renderTableCell(in: tableView, for: indexPath)
    }

    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return sections[section].renderTableHeader(in: tableView, for: section)
    }

    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return sections[section].renderTableFooter(in: tableView, for: section)
    }
}
