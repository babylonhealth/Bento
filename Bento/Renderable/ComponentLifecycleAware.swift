@available(*, deprecated, message:"Implement the component lifecycle methods instead.")
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

    // NOTE: ⚠️ WARNING
    // These callbacks should not provide users direct access to the view hierarchy, as per the Bento Component
    // Contract.

    override func willDisplay(_ view: UIView) {
        super.willDisplay(view)
        _willDisplayItem?()
    }

    override func didEndDisplaying(_ view: UIView) {
        super.didEndDisplaying(view)
        _didEndDisplayingItem?()
    }
}
