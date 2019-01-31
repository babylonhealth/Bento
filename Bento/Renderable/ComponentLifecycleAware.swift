protocol ComponentLifecycleAware {
    func willDisplayItem()
    func didEndDisplayingItem()
}

public protocol ViewLifecycleAware {
    func willDisplayView()
    func didEndDisplayingView()
}

final class LifecycleComponent<Base: Renderable>: AnyRenderableBox<Base>, ComponentLifecycleAware {
    private let source: AnyRenderableBox<Base>
    private let _willDisplayItem: (() -> Void)?
    private let _didEndDisplayingItem: (() -> Void)?

    init(
        source: Base,
        willDisplayItem: (() -> Void)?,
        didEndDisplayingItem: (() -> Void)?
    ) {
        self.source = AnyRenderableBox(source)
        self._willDisplayItem = willDisplayItem
        self._didEndDisplayingItem = didEndDisplayingItem
        super.init(source)
    }

    override func cast<T>(to type: T.Type) -> T? {
        if type == ComponentLifecycleAware.self {
            return self as? T
        }
        return source.cast(to: type)
    }

    func willDisplayItem() {
        _willDisplayItem?()
    }

    func didEndDisplayingItem() {
        _didEndDisplayingItem?()
    }
}
