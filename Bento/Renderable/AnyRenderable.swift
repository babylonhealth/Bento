import UIKit

public struct AnyRenderable: Renderable {
    public var reuseIdentifier: String {
        return base.reuseIdentifier
    }

    var viewType: Any.Type {
        return base.viewType
    }

    fileprivate let base: AnyRenderableBoxBase

    init<Base: Renderable>(_ base: Base) where Base.View: UIView {
        self.base = AnyRenderableBox(base)
    }

    init(_ base: AnyRenderableBoxBase) {
        self.base = base
    }

    public func generate() -> UIView {
        return base.generate()
    }

    public func render(in view: UIView) {
        base.render(in: view)
    }

    func cast<T>(to type: T.Type) -> T? {
        return base.cast(to: type)
    }

    func sizeBoundTo(width: CGFloat, inheritedMargins: UIEdgeInsets) -> CGSize {
        return rendered(inheritedMargins: inheritedMargins)
            .systemLayoutSizeFitting(CGSize(width: width, height: UIView.layoutFittingCompressedSize.height),
                                     withHorizontalFittingPriority: .required,
                                     verticalFittingPriority: .defaultLow)
    }

    func sizeBoundTo(height: CGFloat, inheritedMargins: UIEdgeInsets) -> CGSize {
        return rendered(inheritedMargins: inheritedMargins)
            .systemLayoutSizeFitting(CGSize(width: UIView.layoutFittingCompressedSize.width, height: height),
                                     withHorizontalFittingPriority: .defaultLow,
                                     verticalFittingPriority: .required)
    }

    func sizeBoundTo(size: CGSize, inheritedMargins: UIEdgeInsets) -> CGSize {
        return rendered(inheritedMargins: inheritedMargins)
            .systemLayoutSizeFitting(size)
    }

    private func rendered(inheritedMargins: UIEdgeInsets) -> UIView {
        let view = generate()
        render(in: view)

        let margins = view.layoutMargins
        view.layoutMargins = UIEdgeInsets(top: max(margins.top, inheritedMargins.top),
                                          left: max(margins.left, inheritedMargins.left),
                                          bottom: max(margins.bottom, inheritedMargins.bottom),
                                          right: max(margins.right, inheritedMargins.right))

        return view
    }

    public static func layoutEquivalence(_ lhs: AnyRenderable, _ rhs: AnyRenderable) -> LayoutEquivalence {
        return lhs.base.closestLayoutContributor
            .layoutEquivalence(with: rhs.base.closestLayoutContributor)
    }
}

typealias NoLayoutBehavior<Base: Renderable> = AnyRenderableBox<Base> where Base.View: UIView
typealias LayoutContributingBehavior<Base: Renderable> = LayoutContributingBehaviorBox<Base> where Base.View: UIView

class LayoutContributingBehaviorBox<Base: Renderable>: AnyRenderableBox<Base> where Base.View: UIView {
    override var viewType: Any.Type { notImplemented() }
    override var closestLayoutContributor: AnyRenderableBoxBase { return self }
    override func layoutEquivalence(with other: AnyRenderableBoxBase) -> LayoutEquivalence { return .unknown }
}

class AnyRenderableBox<Base: Renderable>: AnyRenderableBoxBase where Base.View: UIView {
    override var reuseIdentifier: String {
        return base.reuseIdentifier
    }

    override var viewType: Any.Type {
        return Base.View.self
    }

    override var closestLayoutContributor: AnyRenderableBoxBase {
        return (base as? AnyRenderable)?.base.closestLayoutContributor ?? self
    }

    let base: Base

    init(_ base: Base) {
        self.base = base
        super.init()
    }

    override func render(in view: UIView) {
        base.render(in: view as! Base.View)
    }

    override func generate() -> UIView {
        return base.generate()
    }

    override func cast<T>(to type: T.Type) -> T? {
        if let anyRenderable = base as? AnyRenderable {
            return anyRenderable.cast(to: type)
        }
        return base as? T
    }

    override func layoutEquivalence(with other: AnyRenderableBoxBase) -> LayoutEquivalence {
        if let other = other as? AnyRenderableBox<Base> {
            return Base.layoutEquivalence(base, other.base)
        }

        // NOTE: Different component types mean always different layouts.
        return .different
    }
}

class AnyRenderableBoxBase {
    var reuseIdentifier: String { notImplemented() }
    var viewType: Any.Type { notImplemented() }

    /// The closest layout contributor from `self`, including `self`. When there are behaviors attached, this is usually
    /// the innermost, original component. But it could also be a layout contributing behavior.
    ///
    /// - warning: If you implement a behavior that would contribute to the layout, you must override
    ///            `closestLayoutContributor` to specify `self`.
    var closestLayoutContributor: AnyRenderableBoxBase { notImplemented() }

    init() {}

    func asAnyRenderable() -> AnyRenderable {
        return AnyRenderable(self)
    }
    func render(in view: UIView) { notImplemented() }
    func generate() -> UIView { notImplemented() }
    func cast<T>(to type: T.Type) -> T? { notImplemented() }

    /// Evaluate whether `self` should have the same layout as `other`.
    ///
    /// - warning: If you implement a behavior that would contribute to the layout, you must override
    ///            `layoutEquivalence(with:)`. In the path leading to `.same`, you must consider the layout equivalence
    ///            of the base components of both `self` and `other`.
    func layoutEquivalence(with other: AnyRenderableBoxBase) -> LayoutEquivalence { notImplemented() }
}

private func notImplemented(function: StaticString = #function) -> Never {
    fatalError("`\(function)` should have been overriden.")
}
