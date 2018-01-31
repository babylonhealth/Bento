import UIKit

struct HeaderFooterNode: Equatable {
    private let component: AnyRenderable

    init<R: Renderable>(component: R) {
        self.component = AnyRenderable(renderable: component)
    }

    static func ==(lhs: HeaderFooterNode, rhs: HeaderFooterNode) -> Bool {
        return lhs.component === rhs.component
    }

    func update(view: UIView) {
        component.render(in: view)
    }

    func render(in tableView: UITableView) -> UIView {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: component.reuseIdentifier) as? TableViewHeaderFooterView else {
            tableView.register(TableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: component.reuseIdentifier)
            return render(in: tableView)
        }
        let componentView: UIView
        if let containedView = header.containedView {
            componentView = containedView
        } else {
            componentView = component.generateView()
            header.install(view: componentView)
        }
        component.render(in: componentView)
        return header
    }
}
