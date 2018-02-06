public struct Node<Identifier: Hashable> {
    let id: Identifier
    private let component: AnyRenderable

    init(id: Identifier, component: AnyRenderable) {
        self.id = id
        self.component = component
    }

    public init<R: Renderable>(id: Identifier, component: R) {
        self.init(id: id, component: AnyRenderable(renderable: component))
    }

    func renderCell(in tableView: UITableView) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: component.reuseIdentifier) as? TableViewCell else {
            tableView.register(TableViewCell.self, forCellReuseIdentifier: component.reuseIdentifier)
            return renderCell(in: tableView)
        }
        let componentView: UIView
        if let containedView = cell.containedView {
            componentView = containedView
        } else {
            componentView = component.generateView()
            cell.install(view: componentView)
        }
        component.render(view: componentView)
        return cell
    }
}

public func |--+<Identifier>(lhs: Node<Identifier>, rhs: Node<Identifier>) -> [Node<Identifier>] {
    return [lhs, rhs]
}

public func |--+<Identifier>(lhs: [Node<Identifier>], rhs: Node<Identifier>) -> [Node<Identifier>] {
    return lhs + [rhs]
}
