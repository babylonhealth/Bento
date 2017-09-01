import UIKit
import ReactiveSwift
import ReactiveCocoa
import enum Result.NoError
import BabylonFoundation

extension FacebookCell: NibLoadableCell {}

final class FacebookCell: FormCell {
    @IBOutlet weak var button: LoadingButton!

    var viewModel: FacebookCellViewModel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setup(viewModel: FacebookCellViewModel) {
        self.viewModel = viewModel
        self.selectionStyle = self.viewModel.selectionStyle
        button.setTitle(viewModel.title, for: .normal)
        button.reactive.pressed = CocoaAction(viewModel.action)
        viewModel.applyFacebookButtonStyle(to: button)

        button.reactive.isEnabled <~ viewModel.isEnabled.and(isFormEnabled).producer
            .take(until: reactive.prepareForReuse)

        button.reactive.isLoading <~ viewModel.isLoading?.producer
            .take(until: reactive.prepareForReuse)
    }
}
