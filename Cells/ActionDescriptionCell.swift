import UIKit
import TTTAttributedLabel

extension ActionDescriptionCell: NibLoadableCell {}

class ActionDescriptionCell: UITableViewCell {

    fileprivate var viewModel: ActionDescriptionCellViewModel!

    @IBOutlet weak var title: TTTAttributedLabel!

    func setup(viewModel: ActionDescriptionCellViewModel) {
        self.viewModel = viewModel
        title.delegate = self

        viewModel.applyTitleStyle(to: title)
        viewModel.applyBackgroundColor(to: [self, title])
        viewModel.setupTitle(to: title)
    }
}

extension ActionDescriptionCell: TTTAttributedLabelDelegate {
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        viewModel.action.apply().start()
    }
}
