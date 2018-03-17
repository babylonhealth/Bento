public struct Node<Identifier: Hashable> {
    let id: Identifier
    let component: AnyRenderable

    init(id: Identifier, component: AnyRenderable) {
        self.id = id
        self.component = component
    }

    public init<R: Renderable>(id: Identifier, component: R) where R.View: UIView {
        self.init(id: id, component: AnyRenderable(component))
    }

    func equals(to other: Node) -> Bool {
        return component == other.component
    }
}

public func <> <RowId, R: Renderable>(id: RowId, component: R) -> Node<RowId> where R.View: UIView {
    return Node(id: id, component: component)
}

public func |--+<Identifier>(lhs: Node<Identifier>, rhs: Node<Identifier>) -> [Node<Identifier>] {
    return [lhs, rhs]
}

public func |--+<Identifier>(lhs: [Node<Identifier>], rhs: Node<Identifier>) -> [Node<Identifier>] {
    return lhs + [rhs]
}
