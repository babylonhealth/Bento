import UIKit

public struct Node<Identifier: Hashable> {
    public let id: Identifier
    let component: AnyRenderable

    init(id: Identifier, component: AnyRenderable) {
        self.id = id
        self.component = component
    }

    public init<R: Renderable>(id: Identifier, component: R) {
        self.init(id: id, component: AnyRenderable(component))
    }

    public func component<T>(as type: T.Type) -> T? {
        return component.cast(to: type)
    }

    public func sizeBoundTo(width: CGFloat, inheritedMargins: UIEdgeInsets = .zero) -> CGSize {
        return component.sizeBoundTo(width: width, inheritedMargins: inheritedMargins)
    }

    public func sizeBoundTo(height: CGFloat, inheritedMargins: UIEdgeInsets = .zero) -> CGSize {
        return component.sizeBoundTo(height: height, inheritedMargins: inheritedMargins)
    }

    public func sizeBoundTo(size: CGSize, inheritedMargins: UIEdgeInsets = .zero) -> CGSize {
        return component.sizeBoundTo(size: size, inheritedMargins: inheritedMargins)
    }
}

public func <> <RowId, R: Renderable>(id: RowId, component: R) -> Node<RowId> {
    return Node(id: id, component: component)
}

public func |---+<Identifier>(lhs: Node<Identifier>, rhs: Node<Identifier>) -> [Node<Identifier>] {
    return [lhs, rhs]
}

public func |---+<Identifier>(lhs: [Node<Identifier>], rhs: Node<Identifier>) -> [Node<Identifier>] {
    return lhs + [rhs]
}
