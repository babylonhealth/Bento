import UIKit
import FlexibleDiff

final class SectionedFormAdapter<SectionId: Hashable, RowId: Hashable>
    : NSObject,
      UITableViewDataSource,
      UITableViewDelegate {
    private var sections: [Section<SectionId, RowId>] = []
    private weak var tableView: UITableView?

    init(with tableView: UITableView) {
        self.sections = []
        self.tableView = tableView
        super.init()
        tableView.dataSource = self
        tableView.delegate = self
    }

    func update(sections: [Section<SectionId, RowId>]) {
        guard let tableView = tableView else {
            return
        }
        let diff = SectionDiff(oldSections: self.sections, newSections: sections)
        self.sections = sections
        diff.apply(to: tableView)
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
