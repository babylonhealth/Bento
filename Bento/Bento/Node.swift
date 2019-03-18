import UIKit

/// Node is kept by a Section. Node requires an identifier for diff algorithm.
/// Node **always has** a visual representation, because a component needs to be provided.
/// To simplify, you can think Node is in Bento the same what a cell is for UITableView.
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

public func |---+<Identifier>(lhs: Node<Identifier>, rhs: Node<Identifier>) -> [Node<Identifier>] {
    return [lhs, rhs]
}

public func |---+<Identifier>(lhs: [Node<Identifier>], rhs: Node<Identifier>) -> [Node<Identifier>] {
    return lhs + [rhs]
}
