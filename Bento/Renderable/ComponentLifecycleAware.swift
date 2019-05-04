public protocol ViewLifecycleAware {
    func willDisplayView()
    func didEndDisplayingView()
}

final class LifecycleComponent<Base: Renderable>: AnyRenderableBox<Base> {
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

    override func willDisplay() {
        super.willDisplay()
        _willDisplayItem?()
    }

    override func didEndDisplaying() {
        super.didEndDisplaying()
        _didEndDisplayingItem?()
    }
}
