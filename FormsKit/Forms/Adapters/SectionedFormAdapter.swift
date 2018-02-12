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
        let diff = TableViewSectionDiff(oldSections: self.sections, newSections: sections)
        self.sections = sections
        diff.apply(to: tableView)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].rows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let component = node(at: indexPath).component
        guard let cell = tableView.dequeueReusableCell(withIdentifier: component.reuseIdentifier) as? TableViewCell else {
            tableView.register(TableViewCell.self, forCellReuseIdentifier: component.reuseIdentifier)
            return self.tableView(tableView, cellForRowAt: indexPath)
        }
        let componentView: UIView
        if let containedView = cell.containedView {
            componentView = containedView
        } else {
            componentView = component.generateView()
            cell.install(view: componentView)
        }
        component.render(in: componentView)
        return cell

    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return sections[section].header
            .map {
                return self.render(node: $0, in: tableView)
            }
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return sections[section].footer
            .map {
                return self.render(node: $0, in: tableView)
            }
    }

    private func node(at indexPath: IndexPath) -> Node<RowId> {
        return sections[indexPath.section][indexPath.row]
    }
    
    private func render(node: HeaderFooterNode, in tableView: UITableView) -> UIView {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: node.component.reuseIdentifier) as? TableViewHeaderFooterView else {
            tableView.register(TableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: node.component.reuseIdentifier)
            return render(node: node, in: tableView)
        }
        let componentView: UIView
        if let containedView = header.containedView {
            componentView = containedView
        } else {
            componentView = node.component.generateView()
            header.install(view: componentView)
        }
        node.component.render(in: componentView)
        return header
    }
}
