import UIKit

struct AnyRenderable: Renderable {
    var reuseIdentifier: String {
        return base.reuseIdentifier
    }

    private let base: AnyRenderableBoxBase

    init<Base: Renderable>(_ base: Base) where Base.View: UIView {
        self.base = AnyRenderableBox(base)
    }
    
    init<Base: Renderable & AnyObject>(_ base: Base) where Base.View: UIView {
        self.base = AnyComponentBox(base)
    }

    func generate() -> UIView {
        return base.generate()
    }

    func render(in view: UIView) {
        base.render(in: view)
    }
    
    func setDidChange(_ didChange: @escaping () -> Void) {
        base.didChange = didChange
    }

    static func ==(lhs: AnyRenderable, rhs: AnyRenderable) -> Bool {
        return lhs.base.equals(to: rhs.base)
    }
}

private class AnyComponentBox<Base: Renderable>: AnyRenderableBoxBase where Base.View: UIView, Base: AnyObject {
    
    override var reuseIdentifier: String {
        return base.reuseIdentifier
    }
    
    fileprivate var base: Base
    
    override var didChange: (() -> Void)? {
        didSet {
            base.didChange = didChange
        }
    }
    
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

    override func equals(to other: AnyRenderableBoxBase) -> Bool {
        guard let other = other as? AnyComponentBox<Base>
            else { return false }
        return self.base == other.base
    }
    
    override func reload() {
        base.didChange?()
    }
}

private class AnyRenderableBox<Base: Renderable>: AnyRenderableBoxBase where Base.View: UIView {
    override var reuseIdentifier: String {
        return base.reuseIdentifier
    }

    private let base: Base
    
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
    
    override func reload() {}

    override func equals(to other: AnyRenderableBoxBase) -> Bool {
        guard let other = other as? AnyRenderableBox<Base>
            else { return false }
        return self.base == other.base
    }
}

private class AnyRenderableBoxBase {
    var didChange: (() -> Void)?
    var reuseIdentifier: String { fatalError() }
    init() {}

    func render(in view: UIView) { fatalError() }
    func generate() -> UIView { fatalError() }
    func equals(to other: AnyRenderableBoxBase) -> Bool { fatalError() }
    func reload() { fatalError() }
}
