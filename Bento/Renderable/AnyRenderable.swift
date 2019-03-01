import UIKit

public struct AnyRenderable: Renderable {
    /// The runtime view type of the wrapped `Renderable`.
    public var viewType: NativeView.Type {
        return base.viewType
    }

    /// The runtime component type of the wrapped `Renderable`.
    public var componentType: Any.Type {
        return base.componentType
    }

    internal var fullyQualifiedTypeName: String {
        /// NOTE: `String.init(reflecting:)` gives the fully qualified type name.
        //        Tests would catch unexpeced type name printing behavior due to Swift runtime changes.
        return String(reflecting: componentType)
    }

    private let base: AnyRenderableBoxBase

    public init<Base: Renderable>(_ base: Base) {
        self.base = AnyRenderableBox(base)
    }

    init(_ base: AnyRenderableBoxBase) {
        self.base = base
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
        let view = viewType.generate()
        render(in: view)

        let margins = view.layoutMargins
        view.layoutMargins = UIEdgeInsets(top: max(margins.top, inheritedMargins.top),
                                          left: max(margins.left, inheritedMargins.left),
                                          bottom: max(margins.bottom, inheritedMargins.bottom),
                                          right: max(margins.right, inheritedMargins.right))

        return view
    }
}

class AnyRenderableBox<Base: Renderable>: AnyRenderableBoxBase {
    override var viewType: NativeView.Type {
        return (base as? AnyRenderable)?.viewType ?? Base.View.self
    }

    override var componentType: Any.Type {
        return (base as? AnyRenderable)?.componentType ?? Base.self
    }

    let base: Base

    init(_ base: Base) {
        self.base = base
        super.init()
    }

    override func render(in view: UIView) {
        base.render(in: view as! Base.View)
    }

    override func cast<T>(to type: T.Type) -> T? {
        if let anyRenderable = base as? AnyRenderable {
            return anyRenderable.cast(to: type)
        }
        return base as? T
    }
}

class AnyRenderableBoxBase {
    var viewType: NativeView.Type { fatalError() }
    var componentType: Any.Type { fatalError() }

    init() {}

    func asAnyRenderable() -> AnyRenderable {
        return AnyRenderable(self)
    }
    func render(in view: UIView) { fatalError() }
    func cast<T>(to type: T.Type) -> T? { fatalError() }
}
