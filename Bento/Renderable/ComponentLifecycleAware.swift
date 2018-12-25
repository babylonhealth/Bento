protocol ComponentLifecycleAware {
    func willDisplayItem()
    func didEndDisplayingItem()
}

public protocol ViewLifecycleAware {
    func willDisplayView()
    func didEndDisplayingView()
}

final class LifecycleComponent<Base: Renderable>: AnyRenderableBox<Base>, ComponentLifecycleAware where Base.View: UIView {
    private let source: AnyRenderableBox<Base>
    private let _willDisplayView: (() -> Void)?
    private let _didEndDisplayingView: (() -> Void)?

    init(
        source: Base,
        willDisplayView: (() -> Void)?,
        didEndDisplayingView: (() -> Void)?
    ) {
        self.source = AnyRenderableBox(source)
        self._willDisplayView = willDisplayView
        self._didEndDisplayingView = didEndDisplayingView
        super.init(source)
    }

    override func cast<T>(to type: T.Type) -> T? {
        if type == ComponentLifecycleAware.self {
            return self as? T
        }
        return source.cast(to: type)
    }

    func willDisplayItem() {
        _willDisplayView?()
    }

    func didEndDisplayingItem() {
        _willDisplayView?()
    }
}
