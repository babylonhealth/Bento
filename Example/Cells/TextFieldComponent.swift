import UIKit
import Bento

final class TextFieldComponent: NSObject, Renderable, Focusable {
    let title: String
    let text: String
    let didUpdate: (String) -> Void
    var focusEligibility: FocusEligibility {
        return text.isEmpty ? .eligible(.empty) : .eligible(.populated)
    }

    init(title: String, text: String, didUpdate: @escaping (String) -> Void) {
        self.title = title
        self.text = text
        self.didUpdate = didUpdate
    }

    func render(in view: View) {
        view.titleLabel.text = title
        view.textField.text = text
        view.didUpdate = didUpdate
    }

    class View: UIStackView {
        let titleLabel: UILabel
        let textField: UITextField
        var didUpdate: ((String) -> Void)?

        init() {
            titleLabel = UILabel()
            textField = UITextField()

            super.init(frame: .zero)

            preservesSuperviewLayoutMargins = true
            isLayoutMarginsRelativeArrangement = true

            addArrangedSubview(titleLabel)
            addArrangedSubview(textField)

            axis = .horizontal
            distribution = .fill
            alignment = .center

            let constraint = titleLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.3)
            constraint.priority = .defaultHigh
            constraint.isActive = true

            let constraint2 = heightAnchor.constraint(greaterThanOrEqualToConstant: 44.0)
            constraint2.priority = .defaultHigh
            constraint2.isActive = true

            textField.delegate = self
            textField.inputAccessoryView = FocusToolbar(view: self)
            textField.addTarget(self, action: #selector(self.textFieldDidChange), for: .editingChanged)
        }

        @available(*, unavailable)
        required init(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

extension TextFieldComponent.View: FocusableView {
    public func focus() {
        textField.becomeFirstResponder()
    }

    public func neighboringFocusEligibilityDidChange() {
        (textField.inputAccessoryView as? FocusToolbar)?.updateAvailability()
        updateReturnKeyType()
        textField.reloadInputViews()
    }
}

extension TextFieldComponent.View: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        updateReturnKeyType()
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        withFocusCoordinator { coordinator in
            if !coordinator.move(.backward) {
                // The coordinator has not done anything regarding the first
                // responder status. Proceed to resign the first responder
                // status as expected.
                textField.resignFirstResponder()
            }
        }

        return false
    }

    @objc private func textFieldDidChange(_ textField: UITextField) {
        didUpdate?(textField.text ?? "")
    }

    private func updateReturnKeyType() {
        withFocusCoordinator { coordinator in
            textField.returnKeyType = coordinator.canMove(.backward)
                ? .next
                : .done
        }
    }
}

final class FocusToolbar: UIToolbar {
    weak var view: (UIView & FocusableView)?
    var backwardButton: UIBarButtonItem!
    var forwardButton: UIBarButtonItem!

    init(view: UIView & FocusableView) {
        self.view = view

        super.init(frame: .zero)

        backwardButton = UIBarButtonItem(barButtonSystemItem: .fastForward, target: self, action: #selector(moveBackward))
        forwardButton = UIBarButtonItem(barButtonSystemItem: .rewind, target: self, action: #selector(moveForward))

        translatesAutoresizingMaskIntoConstraints = false

        let items = [
            forwardButton!,
            backwardButton!,
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismiss))
        ]
        setItems(items, animated: false)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func willMove(toSuperview newSuperview: UIView?) {
        guard newSuperview != nil else { return }
        updateAvailability()
    }

    fileprivate func updateAvailability() {
        view?.withFocusCoordinator { coordinator in
            backwardButton.isEnabled = coordinator.canMove(.backward)
            forwardButton.isEnabled = coordinator.canMove(.forward)
        }
    }

    @objc private func moveBackward() {
        view?.withFocusCoordinator { coordinator in
            _ = coordinator.move(.backward)
        }
    }

    @objc private func moveForward() {
        view?.withFocusCoordinator { coordinator in
            _ = coordinator.move(.forward)
        }
    }

    @objc private func dismiss() {
        view?.endEditing(true)
    }
}

extension UIBarButtonItem {
    func settingEnabled(_ isEnabled: Bool) -> Self {
        self.isEnabled = isEnabled
        return self
    }
}
