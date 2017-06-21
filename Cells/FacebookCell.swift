import UIKit
import ReactiveSwift
import ReactiveCocoa
import enum Result.NoError
import BabylonFoundation

extension FacebookCell: NibLoadableCell {}

final class FacebookCell: UITableViewCell {

    @IBOutlet weak var button: LoadingButton!

    var viewModel: FacebookCellViewModel!

    func setup(viewModel: FacebookCellViewModel) {
        self.viewModel = viewModel
        self.selectionStyle = self.viewModel.selectionStyle
        button.setTitle(viewModel.title, for: .normal)
        button.reactive.pressed = CocoaAction(viewModel.action)
        viewModel.applyFacebookButtonStyle(to: button)

        button.reactive.isLoading
            <~ viewModel.isLoading?
                .signal
                .take(during: reactive.lifetime)
                .take(until: reactive.prepareForReuse)
    }
}
