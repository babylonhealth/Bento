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


    func update(sections: [Section<SectionId, RowId>], with animation: TableViewAnimation) {
        guard let tableView = tableView else {
            return
        }
        let diff = TableViewSectionDiff(oldSections: self.sections,
                                        newSections: sections,
                                        animation: animation)
        self.sections = sections
        diff.apply(to: tableView)
    }
    func update(sections: [Section<SectionId, RowId>]) {
        self.sections = sections
        tableView?.reloadData()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].rows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let component = node(at: indexPath).component
        let reuseIdentifier = component.reuseIdentifier
        guard let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as? TableViewContainerCell else {
            tableView.register(TableViewContainerCell.self, forCellReuseIdentifier: reuseIdentifier)
            return self.tableView(tableView, cellForRowAt: indexPath)
        }
        let componentView: UIView
        if let containedView = cell.containedView {
            componentView = containedView
        } else {
            componentView = component.generate()
            cell.install(view: componentView)
        }

        copyLayoutMargins(from: tableView, to: cell.contentView)
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

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let component = sections[section].header {
            return component.height(forWidth: tableView.bounds.width,
                                    inheritedMargins: HorizontalEdgeInsets(tableView.layoutMargins))
                ?? tableView.sectionHeaderHeight
        }
        return CGFloat.leastNonzeroMagnitude
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if let component = sections[section].footer {
            return component.height(forWidth: tableView.bounds.width,
                                    inheritedMargins: HorizontalEdgeInsets(tableView.layoutMargins))
                ?? tableView.sectionFooterHeight
        }
        return CGFloat.leastNonzeroMagnitude
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let component = sections[indexPath.section].rows[indexPath.row].component
        return component.height(forWidth: tableView.bounds.width,
                                inheritedMargins: HorizontalEdgeInsets(tableView.layoutMargins))
            ?? tableView.rowHeight
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        if let component = sections[section].header {
            return component.estimatedHeight(forWidth: tableView.bounds.width,
                                             inheritedMargins: HorizontalEdgeInsets(tableView.layoutMargins))
                ?? tableView.estimatedSectionHeaderHeight
        }
        return CGFloat.leastNonzeroMagnitude
    }

    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        if let component = sections[section].footer {
            return component.estimatedHeight(forWidth: tableView.bounds.width,
                                             inheritedMargins: HorizontalEdgeInsets(tableView.layoutMargins))
                ?? tableView.estimatedSectionFooterHeight
        }
        return CGFloat.leastNonzeroMagnitude
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let component = sections[indexPath.section].rows[indexPath.row].component
        return component.estimatedHeight(forWidth: tableView.bounds.width,
                                         inheritedMargins: HorizontalEdgeInsets(tableView.layoutMargins))
            ?? tableView.estimatedRowHeight
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let row = sections[indexPath.section].rows[indexPath.row]
        guard row.component.canBeDeleted else {
            return nil
        }

        return [
            UITableViewRowAction(style: .destructive, title: row.component.deleteActionText) { (_, indexPath) in
                self.deleteRow(at: indexPath, actionPerformed: nil)
            }
        ]
    }

    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let row = sections[indexPath.section].rows[indexPath.row]
        guard row.component.canBeDeleted else {
            return UISwipeActionsConfiguration(actions: [])
        }

        let action = UIContextualAction(style: .destructive, title: row.component.deleteActionText) { (_, _, actionPerformed) in
            self.deleteRow(at: indexPath, actionPerformed: actionPerformed)
        }

        return UISwipeActionsConfiguration(actions: [action])
    }

    private func copyLayoutMargins(from tableView: UITableView, to view: UIView) {
        view.layoutMargins = UIEdgeInsets(top: 0,
                                          left: tableView.layoutMargins.left,
                                          bottom: 0,
                                          right: tableView.layoutMargins.right)
    }

    private func deleteRow(at indexPath: IndexPath, actionPerformed: ((Bool) -> Void)?) {
        let row = sections[indexPath.section].rows[indexPath.row]
        row.component.delete()
        sections[indexPath.section].rows.remove(at: indexPath.row)
        tableView?.deleteRows(at: [indexPath], with: .left)
        actionPerformed?(true)
    }

    private func node(at indexPath: IndexPath) -> Node<RowId> {
        return sections[indexPath.section].rows[indexPath.row]
    }
    
    private func render(node: AnyRenderable, in tableView: UITableView) -> UIView {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: node.reuseIdentifier) as? TableViewHeaderFooterView else {
            tableView.register(TableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: node.reuseIdentifier)
            return render(node: node, in: tableView)
        }
        let componentView: UIView
        if let containedView = header.containedView {
            componentView = containedView
        } else {
            componentView = node.generate()
            header.install(view: componentView)
        }

        copyLayoutMargins(from: tableView, to: header.contentView)
        node.render(in: componentView)
        return header
    }
}
