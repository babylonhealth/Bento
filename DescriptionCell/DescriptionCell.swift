import UIKit
import ReactiveSwift

public enum DescriptionHorizontalLayout {
    case fill
    case centeredProportional(Float)
}

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
    case centeredHeadline
    case centeredTime
    case custom(labelStyle: UIViewStyle<UILabel>)
}

extension DescriptionCell: NibLoadableCell {}

final class DescriptionCell: FormCell {
    @IBOutlet weak var descriptionLabel: UILabel!
    private var descriptionLabelWidthConstraint: NSLayoutConstraint?
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

        if let constraint = descriptionLabelWidthConstraint {
            constraint.isActive = false
            descriptionLabelWidthConstraint = nil
        }

        switch viewModel.horizontalLayout {
        case .fill:
            break
        case .centeredProportional(let ratio):
            let constraint = descriptionLabel.widthAnchor
                .constraint(equalTo: contentView.widthAnchor,
                            multiplier: CGFloat(ratio))
            constraint.isActive = true
            descriptionLabelWidthConstraint = constraint
        }

        tapRecognizer.isEnabled = viewModel.selected != nil
    }

    @objc private func userDidTapLabel() {
        viewModel.selected?.apply().start()
    }
}
