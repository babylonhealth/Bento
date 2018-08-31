protocol BentoReusableView: AnyObject {
    var containedView: UIView? { get set }
    var contentView: UIView { get }
}

extension BentoReusableView {
    func bind(_ component: AnyRenderable?) {
        if let component = component {
            let renderingView: UIView

            if let view = containedView, type(of: view) == component.viewType {
                renderingView = view
            } else {
                renderingView = component.generate()
                containedView = renderingView
            }

            component.render(in: renderingView)
        } else {
            containedView = nil
        }
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
