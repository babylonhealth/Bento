import UIKit

extension Renderable {
    public func customInput(
        _ input: CustomInput,
        contentStatus: FocusEligibility.ContentStatus = .empty,
        highlightColor: UIColor? = UIColor(red: 239/255.0, green: 239/255.0, blue: 244/255.0, alpha: 1)
    ) -> AnyRenderable {
        return CustomInputComponent(
            source: self,
            customInput: input,
            contentStatus: contentStatus,
            highlightColor: highlightColor
        ).asAnyRenderable()
    }
}

struct CustomInputComponent: Renderable, Focusable {
    let customInput: CustomInput
    let focusEligibility: FocusEligibility
    let highlightColor: UIColor?
    let base: AnyRenderable

    init<Base: Renderable>(
        source: Base,
        customInput: CustomInput,
        contentStatus: FocusEligibility.ContentStatus,
        highlightColor: UIColor?
    ) {
        self.customInput = customInput
        self.highlightColor = highlightColor
        self.base = AnyRenderable(source)
        self.focusEligibility = .eligible(contentStatus)
    }

    func render(in view: ComponentView) {
        view.inputNodes = customInput
        view.highlightingGesture.didTap = .manual
        view.highlightingGesture.highlightColor = highlightColor
        view.highlightingGesture.stylingView = view.containedView

        view.renderContent(base)
    }

    func willDisplay(_ view: CustomInputComponent.ComponentView) {
        view.isDisplaying = true
    }

    func didEndDisplaying(_ view: CustomInputComponent.ComponentView) {
        view.isDisplaying = false
    }
}

extension CustomInputComponent {
    final class ComponentView: InteractiveView, FocusableView, ViewStorageOwner {
        var inputNodes: CustomInput? {
            didSet {
                guard isFirstResponder else { return }
                if let nodes = inputNodes {
                    customInputView?.update(nodes)
                    reloadInputViews()
                } else {
                    _ = resignFirstResponder()
                }
            }
        }

        var customInputView: InputView?
        var focusToolbar: FocusToolbar?
        var containedComponent: AnyRenderable?
        var containedView: UIView?
        var storage: [StorageKey : Any] = [:]
        var isDisplaying: Bool = false {
            didSet {
                if oldValue != isDisplaying {
                    visibilityDidChange()
                }
            }
        }

        override init(frame: CGRect) {
            super.init(frame: frame)
        }

        @available(*, unavailable)
        required init?(coder aDecoder: NSCoder) { fatalError() }

        public override var inputView: UIView? {
            return customInputView
        }

        public override var inputAccessoryView: UIView? {
            return focusToolbar
        }

        public override func becomeFirstResponder() -> Bool {
            if let nodes = inputNodes {
                customInputView = InputView()
                focusToolbar = FocusToolbar(view: self)
                customInputView!.update(nodes)
            }

            if super.becomeFirstResponder() {
                highlightingGesture.isHighlighted = true

                NotificationCenter.default.addObserver(
                    self,
                    selector: #selector(keyboardDidDisappear),
                    name: UIResponder.keyboardDidHideNotification,
                    object: nil
                )

                return true
            }

            customInputView = nil
            focusToolbar = nil
            return false
        }

        public override func resignFirstResponder() -> Bool {
            highlightingGesture.isHighlighted = false
            return super.resignFirstResponder()
        }

        public func focus() {
            _ = becomeFirstResponder()
        }

        fileprivate func renderContent(_ component: AnyRenderable) {
            if containedComponent?.componentType == component.componentType,
               let view = containedView,
               type(of: view) == component.viewType {
                component.render(in: view)
                return
            }

            if let view = containedView, let oldComponent = containedComponent {
                if isDisplaying {
                    oldComponent.didEndDisplaying(view)
                }

                oldComponent.willUnmount(from: view, storage: ViewStorage(componentType: oldComponent.componentType, view: self))
                view.removeFromSuperview()
            }

            containedView = component.viewType.generate().with {
                $0.add(to: self).pinEdges(to: self)
                component.didMount(to: $0, storage: ViewStorage(componentType: component.componentType, view: self))
                component.render(in: $0)

                if isDisplaying {
                    component.willDisplay($0)
                }
            }
        }

        private func neighboringFocusEligibilityDidChange() {
            focusToolbar?.updateFocusEligibility(with: self)
            reloadInputViews()
        }

        private func visibilityDidChange() {
            guard let view = containedView else { return }

            if isDisplaying {
                containedComponent?.willDisplay(view)
            } else {
                containedComponent?.didEndDisplaying(view)
            }
        }

        @objc func keyboardDidDisappear() {
            if isFirstResponder { _ = resignFirstResponder() }
            customInputView = nil
            focusToolbar = nil
            NotificationCenter.default.removeObserver(
                self,
                name: UIResponder.keyboardDidHideNotification,
                object: nil
            )
        }
    }
}
