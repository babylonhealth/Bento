import UIKit

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

    func update(sections:[Section<SectionId, RowId>]) {
//        TODO: Add diffing
        self.sections = sections
        tableView?.reloadData()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].rowsCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return sections[indexPath.section].renderCell(in: tableView, at: indexPath.row)
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return sections[section].renderHeader(in: tableView)
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return sections[section].renderFooter(in: tableView)
    }
}
