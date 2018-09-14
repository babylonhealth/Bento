import UIKit
import FlexibleDiff

public typealias TableViewAdapter<SectionID: Hashable, ItemID: Hashable> = TableViewAdapterBase<SectionID, ItemID> & UITableViewDataSource & UITableViewDelegate

open class TableViewAdapterBase<SectionID: Hashable, ItemID: Hashable>
    : NSObject, FocusEligibilitySourceImplementing {
    public final var sections: [Section<SectionID, ItemID>] = []
    internal weak var tableView: UITableView?

    public init(with tableView: UITableView) {
        self.sections = []
        self.tableView = tableView
        super.init()
    }

    func update(sections: [Section<SectionID, ItemID>], with animation: TableViewAnimation) {
        guard let tableView = tableView else {
            return
        }
        let diff = TableViewSectionDiff(oldSections: self.sections,
                                        newSections: sections,
                                        animation: animation)
        self.sections = sections
        diff.apply(to: tableView)
    }

    func update(sections: [Section<SectionID, ItemID>]) {
        self.sections = sections
        tableView?.reloadData()
    }

    @objc(numberOfSectionsInTableView:)
    open func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    @objc open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }

    @objc(tableView:cellForRowAtIndexPath:)
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let component = node(at: indexPath).component
        let reuseIdentifier = component.reuseIdentifier

        guard let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as? TableViewContainerCell else {
            tableView.register(TableViewContainerCell.self, forCellReuseIdentifier: reuseIdentifier)
            return self.tableView(tableView, cellForRowAt: indexPath)
        }

        cell.bind(component)
        return cell

    }

    @objc open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return sections[section].supplements[.header]
            .map { self.render($0, in: tableView) }
    }

    @objc open func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return sections[section].supplements[.footer]
            .map { self.render($0, in: tableView) }
    }

    @objc open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return sections[section].supplements.keys.contains(.header) ? UITableViewAutomaticDimension : .leastNonzeroMagnitude
    }

    @objc open func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return sections[section].supplements.keys.contains(.footer) ? UITableViewAutomaticDimension : .leastNonzeroMagnitude
    }

    @objc(tableView:editActionsForRowAtIndexPath:)
    open func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let item = sections[indexPath.section].items[indexPath.row]
        guard let component = item.component(as: Deletable.self),
              component.canBeDeleted else {
            return nil
        }

        return [
            UITableViewRowAction(style: .destructive, title: component.deleteActionText) { (_, indexPath) in
                self.deleteRow(at: indexPath, actionPerformed: nil)
            }
        ]
    }

    @available(iOS 11.0, *)
    @objc(tableView:trailingSwipeActionsConfigurationForRowAtIndexPath:)
    open func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let item = sections[indexPath.section].items[indexPath.row]
        guard let component = item.component(as: Deletable.self),
              component.canBeDeleted else {
            return UISwipeActionsConfiguration(actions: [])
        }

        let action = UIContextualAction(style: .destructive, title: component.deleteActionText) { (_, _, actionPerformed) in
            self.deleteRow(at: indexPath, actionPerformed: actionPerformed)
        }

        return UISwipeActionsConfiguration(actions: [action])
    }

    private func deleteRow(at indexPath: IndexPath, actionPerformed: ((Bool) -> Void)?) {
        let item = sections[indexPath.section].items[indexPath.row]
        guard let component = item.component(as: Deletable.self) else {
            actionPerformed?(false)
            return
        }

        sections[indexPath.section].items.remove(at: indexPath.row)

        CATransaction.begin()
        CATransaction.setCompletionBlock {
            component.delete()
        }
        tableView?.deleteRows(at: [indexPath], with: .left)
        actionPerformed?(true)
        CATransaction.commit()
    }

    private func node(at indexPath: IndexPath) -> Node<ItemID> {
        return sections[indexPath.section].items[indexPath.row]
    }
    
    private func render(_ component: AnyRenderable, in tableView: UITableView) -> UIView {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: component.reuseIdentifier) as? TableViewHeaderFooterView else {
            tableView.register(TableViewHeaderFooterView.self,
                               forHeaderFooterViewReuseIdentifier: component.reuseIdentifier)
            return render(component, in: tableView)
        }
        header.bind(component)
        return header
    }
}

internal final class BentoTableViewAdapter<SectionID: Hashable, ItemID: Hashable>
    : TableViewAdapterBase<SectionID, ItemID>,
      UITableViewDataSource,
      UITableViewDelegate
{}
