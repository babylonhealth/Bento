import UIKit
import ReactiveSwift

public enum DescriptionCellType {
    case header
    case headline
    case link
    case footer
    case alert
    case captionText
    case centeredTitle
    case centeredTitleWithDisclosureIndicator
    case centeredSubtitle
    case custom(labelStyle: UIViewStyle<UILabel>)
}

extension DescriptionCell: NibLoadableCell {}

final class DescriptionCell: FormCell {
    @IBOutlet weak var descriptionLabel: UILabel!
    private var tapRecognizer: UITapGestureRecognizer!

    var viewModel: DescriptionCellViewModel!

    override func awakeFromNib() {
        super.awakeFromNib()

        tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.addTarget(self, action: #selector(self.userDidTapLabel))
        descriptionLabel.addGestureRecognizer(tapRecognizer)

        descriptionLabel.reactive.isUserInteractionEnabled <~ isFormEnabled
    }

    func setup(viewModel: DescriptionCellViewModel) {
        self.viewModel = viewModel
        self.viewModel.applyStyle(to: self.descriptionLabel)
        self.viewModel.applyText(to: self.descriptionLabel)
        self.viewModel.applyBackgroundColor(to: [self, self.descriptionLabel])
        self.selectionStyle = self.viewModel.selectionStyle

        tapRecognizer.isEnabled = viewModel.selected != nil
    }

    @objc private func userDidTapLabel() {
        viewModel.selected?.apply().start()
    }
}
