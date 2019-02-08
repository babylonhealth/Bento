import UIKit

public protocol Renderable {
    associatedtype View

    var reuseIdentifier: String { get }

    func generate() -> View

    /// Render `self` to the given view.
    ///
    /// - parameters:
    ///   - view: The view to render `self` in.
    func render(in view: View)

    /// Evaluate whether two instances of `Self` result in compatible layouts.
    ///
    /// In absence of a layout compatibility definition, Bento would be conservative regarding caching of information at
    /// the given ID path.
    ///
    /// - important: Layout evaluation is performed only on the root component, in the case of infinitely nested
    ///              `AnyRenderable` wrapping with or without added behaviors.
    ///
    /// - parameters:
    ///   - lhs: The first component to evaluate.
    ///   - rhs: The second component to evaluate.
    ///
    /// - returns: A `LayoutEquivalence` value specifying the layout compatibility.
    static func layoutEquivalence(_ lhs: Self, _ rhs: Self) -> LayoutEquivalence
}

public extension Renderable {
    static func layoutEquivalence(_ lhs: Self, _ rhs: Self) -> LayoutEquivalence {
        return .unknown
    }

    var reuseIdentifier: String {
        return String(reflecting: View.self)
    }
}

public extension Renderable where View: UIView {
    func generate() -> View {
        return View()
    }
}

public extension Renderable where View: UIView & NibLoadable {
    func generate() -> View {
        return View.loadFromNib()
    }
}

public extension Renderable where View: UIView {

    func deletable(
        deleteActionText: String,
        backgroundColor: UIColor? = nil,
        didDelete: @escaping () -> Void
    ) -> AnyRenderable {
        return DeletableComponent(
            source: self,
            deleteActionText: deleteActionText,
            backgroundColor: backgroundColor,
            didDelete: didDelete
        ).asAnyRenderable()
    }

    func on(willDisplayItem: (() -> Void)? = nil, didEndDisplayingItem: (() -> Void)? = nil) -> AnyRenderable {
        return LifecycleComponent(
            source: self,
            willDisplayItem: willDisplayItem,
            didEndDisplayingItem: didEndDisplayingItem
        ).asAnyRenderable()
    }
}
