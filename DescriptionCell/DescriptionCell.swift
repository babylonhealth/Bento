import UIKit
import ReactiveSwift

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

        selectionStyle = .none
    }

    func setup(viewModel: DescriptionCellViewModel) {
        self.viewModel = viewModel

        switch (viewModel.style, viewModel.weight) {
        case let (.system(style), weight?):
            let size = UIFont.preferredFont(forTextStyle: style).pointSize
            descriptionLabel.font = UIFont.systemFont(ofSize: size, weight: weight)
        case let (.system(style), .none):
            descriptionLabel.font = UIFont.preferredFont(forTextStyle: style)
        case let (.monospacedDigit(size), weight):
            descriptionLabel.font = UIFont.monospacedDigitSystemFont(ofSize: CGFloat(size),
                                                                     weight: weight ?? .regular)
        }

        descriptionLabel.textColor = viewModel.color

        switch (viewModel.alignment, effectiveUserInterfaceLayoutDirection) {
        case (.leading, .leftToRight):
            descriptionLabel.textAlignment = .left
        case (.trailing, .leftToRight):
            descriptionLabel.textAlignment = .right
        case (.leading, .rightToLeft):
            descriptionLabel.textAlignment = .right
        case (.trailing, .rightToLeft):
            descriptionLabel.textAlignment = .left
        case (.center, _):
            descriptionLabel.textAlignment = .center
        }

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

        if viewModel.showsDisclosureIndicator {
            let attachment = NSTextAttachment()
            attachment.image = UIImage(named: "descriptionCellDisclosureIndicator",
                                       in: Bundle(for: DescriptionCell.self),
                                       compatibleWith: nil)

            let text = NSMutableAttributedString(string: viewModel.text)
            text.append(NSAttributedString(string: " "))
            text.append(NSAttributedString(attachment: attachment))

            descriptionLabel.attributedText = text
        } else {
            descriptionLabel.text = viewModel.text
        }

        tapRecognizer.isEnabled = viewModel.selected != nil
    }

    @objc private func userDidTapLabel() {
        viewModel.selected?.apply().start()
    }
}
