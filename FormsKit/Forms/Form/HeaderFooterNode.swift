import UIKit

public struct HeaderFooterNode {
    private let component: AnyRenderable

    public init<R: Renderable>(component: R) {
        self.component = AnyRenderable(renderable: component)
    }

    func render(in tableView: UITableView) -> UIView? {
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
        component.render(view: componentView)
        return header
    }
}
