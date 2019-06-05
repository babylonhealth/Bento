import UIKit

extension Renderable {
    /// Sets up `customInput` to prepare for presention when user taps `self`.
    public func customInput(
        _ input: CustomInput,
        contentStatus: FocusEligibility.ContentStatus = .empty,
        highlightColor: UIColor? = UIColor(red: 239/255.0, green: 239/255.0, blue: 244/255.0, alpha: 1)
    ) -> AnyRenderable {
        return CustomInputComponent(
            source: self,
            customInput: input,
            focusEligibility: .eligible(contentStatus),
            highlightColor: highlightColor,
            focusesOnFirstDisplay: false
        ).asAnyRenderable()
    }

    /// Sets up `customInput` to prepare for presention when user taps `self`,
    /// and also presents it immediately when `state` is `.some`.
    ///
    /// - important: This method is useful when `customInput` needs to be displayed asynchronously after state change.
    /// - note: Due to asynchronous presentation, `focusEligibility` is not supported.
    public func customInputImmediately<State>(
        when state: State?,
        input: (State) -> CustomInput,
        highlightColor: UIColor? = UIColor(red: 239/255.0, green: 239/255.0, blue: 244/255.0, alpha: 1)
    ) -> AnyRenderable {
        return CustomInputComponent(
            source: self,
            customInput: state.map(input),
            focusEligibility: .ineligible,
            highlightColor: highlightColor,
            focusesOnFirstDisplay: state != nil
        ).asAnyRenderable()
    }
}

struct CustomInputComponent: Renderable, Focusable {
    let customInput: CustomInput?
    let focusEligibility: FocusEligibility
    let highlightColor: UIColor?
    let focusesOnFirstDisplay: Bool

    let base: AnyRenderable

    init<Base: Renderable>(
        source: Base,
        customInput: CustomInput?,
        focusEligibility: FocusEligibility,
        highlightColor: UIColor?,
        focusesOnFirstDisplay: Bool
    ) {
        self.customInput = customInput
        self.highlightColor = highlightColor
        self.base = AnyRenderable(source)
        self.focusEligibility = focusEligibility
        self.focusesOnFirstDisplay = focusesOnFirstDisplay
    }

    func render(in view: ComponentView) {
        view.inputNodes = customInput
        view.isFocusEnabled = focusEligibility.isEligible(skipsPopulatedComponents: false)
        view.highlightingGesture.didTap = .manual
        view.highlightingGesture.highlightColor = highlightColor
        view.highlightingGesture.stylingView = view.containedView

        view.bind(base)

        if focusesOnFirstDisplay && view.canBecomeFirstResponder && !view.isFirstResponder {
            _ = view.becomeFirstResponder()
        }
    }

    func willDisplay(_ view: CustomInputComponent.ComponentView) {
        view.isDisplaying = true
    }

    func didEndDisplaying(_ view: CustomInputComponent.ComponentView) {
        view.isDisplaying = false
    }
}

extension CustomInputComponent {
    final class ComponentView: InteractiveView, FocusableView {
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

        fileprivate(set) var isFocusEnabled: Bool = true

        var customInputView: InputView?
        var focusToolbar: FocusToolbar?
        var component: AnyRenderable?

        var containedView: UIView? {
            didSet {
                containerViewDidChange(from: oldValue, to: containedView)
            }
        }
        
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
                focusToolbar = FocusToolbar(view: self, isFocusEnabled: isFocusEnabled)
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

        private func neighboringFocusEligibilityDidChange() {
            focusToolbar?.updateFocusEligibility(with: self)
            reloadInputViews()
        }

        private func visibilityDidChange() {
            guard let view = containedView else { return }

            if isDisplaying {
                component?.willDisplay(view)
            } else {
                component?.didEndDisplaying(view)
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

extension CustomInputComponent.ComponentView: BentoReusableView {
    var contentView: UIView { return self }
}
