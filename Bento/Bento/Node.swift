import UIKit

public struct Node<Identifier: Hashable>: Equatable {
    public let id: Identifier
    let component: AnyRenderable

    init(id: Identifier, component: AnyRenderable) {
        self.id = id
        self.component = component
    }

    public init<R: Renderable>(id: Identifier, component: R) where R.View: UIView {
        self.init(id: id, component: AnyRenderable(component))
    }

    public init<R: Deletable>(id: Identifier, component: R) where R.View: UIView {
        self.init(id: id, component: AnyRenderable(component))
    }

    public static func == (lhs: Node, rhs: Node) -> Bool {
        return lhs.id == rhs.id && lhs.component == rhs.component
    }

    public func component<T>(as type: T.Type) -> T? {
        return component.cast(to: type)
    }

    public func sizeBoundTo(width: CGFloat) -> CGSize {
        return component.sizeBoundTo(width: width)
    }

    public func sizeBoundTo(height: CGFloat) -> CGSize {
        return component.sizeBoundTo(height: height)
    }

    public func sizeBoundTo(size: CGSize) -> CGSize {
        return component.sizeBoundTo(size: size)
    }
}

public func <> <RowId, R: Renderable>(id: RowId, component: R) -> Node<RowId> where R.View: UIView {
    return Node(id: id, component: component)
}

public func <> <RowId, R: Deletable>(id: RowId, component: R) -> Node<RowId> where R.View: UIView {
    return Node(id: id, component: component)
}


public func |---+<Identifier>(lhs: Node<Identifier>, rhs: Node<Identifier>) -> [Node<Identifier>] {
    return [lhs, rhs]
}

public func |---+<Identifier>(lhs: [Node<Identifier>], rhs: Node<Identifier>) -> [Node<Identifier>] {
    return lhs + [rhs]
}
