import Bento
import UIKit

public final class FocusToolbar: UIToolbar {
    private let backwardButton: UIBarButtonItem
    private let forwardButton: UIBarButtonItem
    private let doneButton: UIBarButtonItem
    private var view: (UIView & FocusableView)?

    public init(view: UIView & FocusableView) {
        backwardButton = UIBarButtonItem(
            image: UIImage(named: "arrow_down", in: Resources.bundle, compatibleWith: nil)!,
            style: .plain,
            target: nil,
            action: nil
        )
        forwardButton = UIBarButtonItem(
            image: UIImage(named: "arrow_up", in: Resources.bundle, compatibleWith: nil)!,
            style: .plain,
            target: nil,
            action: nil
        )
        doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: nil, action: nil)
        
        self.view = view
        super.init(frame: .zero)

        translatesAutoresizingMaskIntoConstraints = false
        backwardButton.target = self
        backwardButton.action = #selector(backButtonPressed)
        forwardButton.target = self
        forwardButton.action = #selector(forwardButtonPressed)
        doneButton.target = self
        doneButton.action = #selector(doneButtonPressed)
        let items = [
            forwardButton,
            backwardButton,
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            doneButton
        ]
        setItems(items, animated: false)
        updateFocusEligibility(with: view)
    }

    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func updateFocusEligibility(with view: UIView & FocusableView) {
        view.withFocusCoordinator { coordinator in
            backwardButton.isEnabled = coordinator.canMove(.backward)
            forwardButton.isEnabled = coordinator.canMove(.forward)
        }
    }

    @objc
    private func backButtonPressed() {
        view?.withFocusCoordinator {
            _ = $0.move(.backward)
        }
    }

    @objc
    private func forwardButtonPressed() {
        view?.withFocusCoordinator {
            _ = $0.move(.forward)
        }
    }

    @objc
    private func doneButtonPressed() {
        view?.endEditing(true)
    }
}
