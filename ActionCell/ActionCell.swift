import UIKit
import ReactiveSwift
import ReactiveCocoa
import enum Result.NoError
import BabylonFoundation

extension ActionCell: NibLoadableCell {}

final class ActionCell: FormCell {
    @IBOutlet weak var button: LoadingButton!
    @IBOutlet var heightConstraint: NSLayoutConstraint!

    var viewModel: ActionCellViewModel!
    private var isWaitingForCompletion: Bool = false

    override var canBecomeFirstResponder: Bool {
        return true
    }

    func setup(viewModel: ActionCellViewModel, spec: ActionCellViewSpec) {
        self.viewModel = viewModel

        selectionStyle = spec.selectionStyle
        button.setTitle(spec.title, for: .normal)
        
        heightConstraint.isActive = !spec.hasDynamicHeight

        let buttonMargin = viewModel.margins ?? spec.buttonMargins

        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: buttonMargin),
            button.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -buttonMargin)
            ])

        button.reactive.controlEvents(.primaryActionTriggered)
            .take(until: reactive.prepareForReuse)
            .observeValues { [weak self] _ in
                // Steal the first responder to dismiss the active input view.
                self?.becomeFirstResponder()
                self?.resignFirstResponder()

                self?.isWaitingForCompletion = true
                viewModel.action.apply(()).start { event in
                    if event.isTerminating {
                        self?.isWaitingForCompletion = false
                    }
                }
            }

        button.reactive.isEnabled <~ viewModel.action.isEnabled.and(isFormEnabled).producer
            .take(until: reactive.prepareForReuse)
            .observe(on: UIScheduler())
            .injectSideEffect { [weak self] isEnabled in
                guard let strongSelf = self, !strongSelf.isWaitingForCompletion
                    else { return }

                UIView.animate(withDuration: 0.25) {
                    if isEnabled {
                        spec.buttonStyle.apply(to: strongSelf.button)
                    } else {
                        spec.disabledButtonStyle?.apply(to: strongSelf.button)
                    }
                }
            }

        button.reactive.isLoading <~ viewModel.isLoading?.producer
            .take(until: reactive.prepareForReuse)
    }
}
