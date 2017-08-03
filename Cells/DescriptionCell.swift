import UIKit

public enum DescriptionCellType {
    case header
    case headline
    case link
    case footer
    case alert
}

extension DescriptionCell: NibLoadableCell {}

final class DescriptionCell: FormCell {
    @IBOutlet weak var descriptionLabel: UILabel!

    var viewModel: DescriptionCellViewModel!

    func setup(viewModel: DescriptionCellViewModel) {
        self.viewModel = viewModel
        self.viewModel.applyStyle(to: self.descriptionLabel)
        self.viewModel.applyText(to: self.descriptionLabel)
        self.viewModel.applyBackgroundColor(to: [self, self.descriptionLabel])
        self.selectionStyle = self.viewModel.selectionStyle
    }
}
