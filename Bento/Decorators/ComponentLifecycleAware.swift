public protocol ComponentLifecycleAware {
    func willDisplayItem()
    func didEndDisplayingItem()
}

public protocol ViewLifecycleAware {
    func willDisplayView()
    func didEndDisplayingView()
}

extension Renderable {
    public func on(willDisplayItem: (() -> Void)? = nil, didEndDisplayingItem: (() -> Void)? = nil) -> AnyRenderable {
        return LifecycleComponent(
            source: self,
            willDisplayItem: willDisplayItem,
            didEndDisplayingItem: didEndDisplayingItem
        ).asAnyRenderable()
    }
}

final class LifecycleComponent<Base: Renderable>: AnyRenderableBox<Base>, ComponentLifecycleAware {
    private let _willDisplayItem: (() -> Void)?
    private let _didEndDisplayingItem: (() -> Void)?

    init(
        source: Base,
        willDisplayItem: (() -> Void)?,
        didEndDisplayingItem: (() -> Void)?
    ) {
        self._willDisplayItem = willDisplayItem
        self._didEndDisplayingItem = didEndDisplayingItem
        super.init(source)
    }

    override func cast<T>(to type: T.Type) -> T? {
        if type == ComponentLifecycleAware.self {
            return self as? T
        }
        return super.cast(to: type)
    }

    func willDisplayItem() {
        _willDisplayItem?()
    }

    func didEndDisplayingItem() {
        _didEndDisplayingItem?()
    }
}
