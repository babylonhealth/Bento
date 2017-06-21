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

    func setup(viewModel: ActionCellViewModel) {
        self.viewModel = viewModel
        self.selectionStyle = self.viewModel.selectionStyle

        viewModel.applyStyle(to: button)
        
        heightConstraint.isActive = !viewModel.hasDynamicHeight

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
