import UIKit

extension SeparatorCell: NibLoadableCell {}

final class SeparatorCell: UITableViewCell {

	var viewModel: SeparatorCellViewModel!

	@IBOutlet weak var separator: UIView!
	@IBOutlet weak var leadingConstraint: NSLayoutConstraint!

	func setup(viewModel: SeparatorCellViewModel) {
		self.viewModel = viewModel
		leadingConstraint.constant = CGFloat(self.viewModel.width)
		self.viewModel.applyBackgroundColor(to: self)
		self.viewModel.applySeparatorColor(to: self.separator)
		self.selectionStyle = viewModel.selectionStyle
	}
}
