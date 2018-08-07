import UIKit

struct AnyRenderable: Renderable, Deletable {
    var canBeDeleted: Bool {
        return base.canBeDeleted
    }

    var deleteActionText: String {
        return base.deleteActionText
    }

    var reuseIdentifier: String {
        return base.reuseIdentifier
    }

    private let base: AnyRenderableBoxBase

    init<Base: Renderable>(_ base: Base) where Base.View: UIView {
        self.base = AnyRenderableBox(base)
    }

    init<Base: Deletable>(_ base: Base) where Base.View: UIView {
        self.base = AnyDeletableBox(base)
    }

    func generate() -> UIView {
        return base.generate()
    }

    func render(in view: UIView) {
        base.render(in: view)
    }

    func height(forWidth width: CGFloat, inheritedMargins: HorizontalEdgeInsets) -> CGFloat? {
        return base.height(forWidth: width, inheritedMargins: inheritedMargins)
    }

    func estimatedHeight(forWidth width: CGFloat, inheritedMargins: HorizontalEdgeInsets) -> CGFloat? {
        return base.estimatedHeight(forWidth: width, inheritedMargins: inheritedMargins)
    }

    func delete() {
        base.delete()
    }

    static func ==(lhs: AnyRenderable, rhs: AnyRenderable) -> Bool {
        return lhs.base.equals(to: rhs.base)
    }
}

private class AnyDeletableBox<Base: Deletable>: AnyRenderableBox<Base> where Base.View: UIView {
    override var canBeDeleted: Bool {
        return base.canBeDeleted
    }

    override var deleteActionText: String {
        return base.deleteActionText
    }

    override init(_ base: Base) {
        super.init(base)
    }

    override func delete() {
        base.delete()
    }
}

private class AnyRenderableBox<Base: Renderable>: AnyRenderableBoxBase where Base.View: UIView {
    override var reuseIdentifier: String {
        return base.reuseIdentifier
    }

    fileprivate let base: Base

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

    override func height(forWidth width: CGFloat, inheritedMargins: HorizontalEdgeInsets) -> CGFloat? {
        return base.height(forWidth: width, inheritedMargins: inheritedMargins)
    }

    override func estimatedHeight(forWidth width: CGFloat, inheritedMargins: HorizontalEdgeInsets) -> CGFloat? {
        return base.estimatedHeight(forWidth: width, inheritedMargins: inheritedMargins)
    }

    override func equals(to other: AnyRenderableBoxBase) -> Bool {
        guard let other = other as? AnyRenderableBox<Base>
            else { return false }
        return self.base == other.base
    }
}

private class AnyRenderableBoxBase {
    var canBeDeleted: Bool {
        return false
    }

    var deleteActionText: String {
        return ""
    }

    var reuseIdentifier: String { fatalError() }

    init() {}

    func render(in view: UIView) { fatalError() }
    func generate() -> UIView { fatalError() }
    func height(forWidth width: CGFloat, inheritedMargins: HorizontalEdgeInsets) -> CGFloat? { fatalError() }
    func estimatedHeight(forWidth width: CGFloat, inheritedMargins: HorizontalEdgeInsets) -> CGFloat? { fatalError() }
    func equals(to other: AnyRenderableBoxBase) -> Bool { fatalError() }
    func delete() {}
}
