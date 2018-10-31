public protocol ComponentLifecycleAware {
    func willDisplayItem()
    func didEndDisplayingItem()
}

public protocol ViewLifecycleAware {
    func willDisplayView()
    func didEndDisplayingView()
}
