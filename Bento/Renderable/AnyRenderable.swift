import UIKit

public struct AnyRenderable: Renderable {
    public var reuseIdentifier: String {
        return base.reuseIdentifier
    }

    var viewType: Any.Type {
        return base.viewType
    }

    private let base: AnyRenderableBoxBase

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
}

class AnyRenderableBox<Base: Renderable>: AnyRenderableBoxBase where Base.View: UIView {
    override var reuseIdentifier: String {
        return base.reuseIdentifier
    }

    override var viewType: Any.Type {
        return (base as? AnyRenderable)?.viewType ?? Base.View.self
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
}

class AnyRenderableBoxBase {
    var reuseIdentifier: String { fatalError() }

    var viewType: Any.Type { fatalError() }

    init() {}

    func asAnyRenderable() -> AnyRenderable {
        return AnyRenderable(self)
    }
    func render(in view: UIView) { fatalError() }
    func generate() -> UIView { fatalError() }
    func cast<T>(to type: T.Type) -> T? { fatalError() }
}
