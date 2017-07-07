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

    override var canBecomeFirstResponder: Bool {
        return true
    }

    func setup(viewModel: ActionCellViewModel, spec: ActionCellViewSpec) {
        self.viewModel = viewModel

        selectionStyle = spec.selectionStyle
        spec.buttonStyle.apply(to: button)
        button.setTitle(spec.title, for: .normal)
        
        heightConstraint.isActive = !spec.hasDynamicHeight

        button.reactive.controlEvents(.primaryActionTriggered)
            .take(until: reactive.prepareForReuse)
            .observeValues { [weak self] _ in
                // Steal the first responder to dismiss the active input view.
                self?.becomeFirstResponder()
                self?.resignFirstResponder()

                viewModel.action.apply(()).start()
            }

        button.reactive.isEnabled <~ viewModel.action.isEnabled.and(isFormEnabled).producer
            .take(until: reactive.prepareForReuse)

        button.reactive.isLoading <~ viewModel.isLoading?.producer
            .take(until: reactive.prepareForReuse)
    }
}
