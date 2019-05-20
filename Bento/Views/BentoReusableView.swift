protocol BentoReusableView: NativeView {
    var containedView: NativeView? { get set }
    var contentView: NativeView { get }
    var component: AnyRenderable? { get set }
    var storage: [StorageKey: Any] { get set }
}

struct StorageKey: Hashable {
    let component: Any.Type
    let identifier: ObjectIdentifier

    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(component))
        hasher.combine(identifier)
    }

    static func == (lhs: StorageKey, rhs: StorageKey) -> Bool {
        return lhs.component == rhs.component && lhs.identifier == rhs.identifier
    }
}

extension BentoReusableView {
    func bind(_ component: AnyRenderable?) {
        let oldComponent = self.component

        // Notify the old component, and clear the view storage.
        oldComponent.zip(with: containedView) {
            $0.willUnmount(
                from: $1,
                storage: ViewStorage(componentType: $0.componentType, view: self)
            )
        }
        storage = [:]

        // Set the new component.
        self.component = component

        if let component = component {
            let renderingView: UIView

            if let view = containedView, oldComponent?.componentType == component.componentType {
                renderingView = view
            } else {
                renderingView = component.viewType.generate()
                containedView = renderingView
            }

            component.render(in: renderingView)
            component.didMount(
                to: renderingView,
                storage: ViewStorage(componentType: component.componentType, view: self)
            )
        } else {
            containedView = nil
        }
    }

    func willDisplayView() {
        if let containedView = containedView {
            component?.willDisplay(containedView)

            containedView.enumerateAllViewsAndSelf { view in
                (view as? ViewLifecycleAware)?.willDisplayView()
            }
        }
    }

    func didEndDisplayingView() {
        if let containedView = containedView {
            component?.didEndDisplaying(containedView)

            containedView.enumerateAllViewsAndSelf { view in
                (view as? ViewLifecycleAware)?.didEndDisplayingView()
            }
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

fileprivate extension UIView {
    func enumerateAllViewsAndSelf(_ action: (UIView) -> Void) {
        action(self)

        for view in subviews {
            view.enumerateAllViewsAndSelf(action)
        }
    }
}
