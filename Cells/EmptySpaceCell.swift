import UIKit

extension EmptySpaceCell: NibLoadableCell {}

final class EmptySpaceCell: UITableViewCell {

    var viewModel: EmptySpaceCellViewModel!

    @IBOutlet weak var heightConstraint: NSLayoutConstraint!

    func setup(viewModel: EmptySpaceCellViewModel) {
        self.viewModel = viewModel
        viewModel.applyBackgroundColor(to: self)
        self.heightConstraint.constant = CGFloat(viewModel.height)
        self.selectionStyle = viewModel.selectionStyle
    }
}
