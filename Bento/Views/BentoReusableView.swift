protocol BentoReusableView: AnyObject {
    var containedView: UIView? { get set }
    var contentView: UIView { get }
    var component: AnyRenderable? { get set }
}

extension BentoReusableView {
    func bind(_ component: AnyRenderable?) {
        self.component = component
        if let component = component {
            let renderingView: UIView

            if let view = containedView, type(of: view) == component.viewType {
                renderingView = view
            } else {
                renderingView = component.viewType.generate()
                containedView = renderingView
            }

            component.render(in: renderingView)
        } else {
            containedView = nil
        }
    }

    func willDisplayView() {
        component?
            .cast(to: ComponentLifecycleAware.self)?
            .willDisplayItem()
        (containedView as? ViewLifecycleAware)?.willDisplayView()
    }

    func didEndDisplayingView() {
        component?
            .cast(to: ComponentLifecycleAware.self)?
            .didEndDisplayingItem()
        (containedView as? ViewLifecycleAware)?.didEndDisplayingView()
    }
}

extension BentoReusableView where Self: UIView {
    func containerViewDidChange(from old: UIView?, to new: UIView?) {
        func add(_ view: UIView) {
            contentView.addSubview(view)
            view.pinToEdges(of: contentView)
        }

        switch (old, new) {
        case let (oldView?, newView?) where UIView.areAnimationsEnabled:
            UIView.transition(
                with: self,
                duration: 0.3,
                options: .transitionCrossDissolve,
                animations: {
                    oldView.removeFromSuperview()
                    add(newView)
                },
                completion: nil
            )
        default:
            old?.removeFromSuperview()

            if let new = new {
                add(new)
            }
        }
    }
}
