import UIKit
import ReactiveSwift
import ReactiveCocoa
import enum Result.NoError
import BabylonFoundation

extension ActionCell: NibLoadableCell {}

final class ActionCell: UITableViewCell {

    @IBOutlet weak var button: LoadingButton!
    @IBOutlet var heightConstraint: NSLayoutConstraint!

    var viewModel: ActionCellViewModel!

    func setup(viewModel: ActionCellViewModel, spec: ActionCellViewSpec) {
        self.viewModel = viewModel

        selectionStyle = spec.selectionStyle
        spec.buttonStyle.apply(to: button)
        button.setTitle(spec.title, for: .normal)
        
        heightConstraint.isActive = !spec.hasDynamicHeight

        button.reactive.pressed = CocoaAction(viewModel.action)

        button.reactive.isEnabled
            <~ viewModel.isInteractable
                .producer
                .take(until: reactive.prepareForReuse)

        button.reactive.isLoading
            <~ viewModel.isLoading?
                .signal
                .take(until: reactive.prepareForReuse)
    }
}
