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
                renderingView = component.generate()
                containedView = renderingView
            }

            component.render(in: renderingView)
            applyAccessoryProvidingBehavior(for: component)
            applySelectableBehavior(for: component)
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
    
    private func applySelectableBehavior(for component: AnyRenderable) {
        guard let cell = self as? UITableViewCell else { return }
        if let selectable = component.cast(to: Selectable.self) {
            if let color = selectable.selectionColor {
                cell.selectionStyle = .default
                cell.selectedBackgroundView = cell.selectedBackgroundView ?? UIView()
                cell.selectedBackgroundView?.backgroundColor = color
            }
            else {
                cell.selectionStyle = .default
                // set system color if it was modified
                cell.selectedBackgroundView?.backgroundColor = UIColor(red:0.83, green:0.83, blue:0.83, alpha:1)
            }
        } else {
            cell.selectionStyle = .none
        }
    }
    
    private func applyAccessoryProvidingBehavior(for component: AnyRenderable) {
        guard let cell = self as? UITableViewCell else { return }
        if let accessoryProviding = component.cast(to: AccessoryProviding.self) {
            cell.accessoryType = accessoryProviding.accessory.cellType
        } else {
            cell.accessoryType = .none
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
