import UIKit

/// Node is kept by a Section. Node requires an identifier for diff algorithm.
/// Node **always has** a visual representation, because a component needs to be provided.
/// To simplify, you can think of a Node in Bento as equivalent to a cell in UITableView / UICollectionView.
public struct Node<Identifier: Hashable> {
    public let id: Identifier
    public let component: AnyRenderable

    init(id: Identifier, component: AnyRenderable) {
        self.id = id
        self.component = component
    }

    public init<R: Renderable>(id: Identifier, component: R) {
        self.init(id: id, component: AnyRenderable(component))
    }
}

public func |---+<Identifier>(lhs: Node<Identifier>, rhs: Node<Identifier>) -> [Node<Identifier>] {
    return [lhs, rhs]
}

public func |---+<Identifier>(lhs: [Node<Identifier>], rhs: Node<Identifier>) -> [Node<Identifier>] {
    return lhs + [rhs]
}
