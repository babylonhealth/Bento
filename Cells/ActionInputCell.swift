import UIKit
import ReactiveSwift

extension ActionInputCell: NibLoadableCell {}

final class ActionInputCell: FormCell {
    private var viewModel: ActionInputCellViewModel!

    @IBOutlet var miniatureIconWidthConstraint: NSLayoutConstraint!
    @IBOutlet var largeRoundAvatarWidthConstraint: NSLayoutConstraint!
    @IBOutlet var largeRoundAvatarVerticalMarginConstraints: [NSLayoutConstraint]!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet var titleLabelMinWidthConstraint: NSLayoutConstraint!

    override var canBecomeFirstResponder: Bool {
        return true
    }

    func setup(viewModel: ActionInputCellViewModel) {
        self.viewModel = viewModel
        viewModel.applyTitleStyle(to: titleLabel)
        viewModel.applyInputStyle(to: subtitleLabel)
        iconView.image = viewModel.icon
        accessoryType = viewModel.accessory
        selectionStyle = viewModel.selectionStyle

        reactive.isUserInteractionEnabled <~ viewModel.isSelected.isEnabled.and(isFormEnabled).producer

        titleLabel.reactive.text <~ viewModel.title.producer
            .take(until: reactive.prepareForReuse)

        if let input = viewModel.input {
            subtitleLabel.isHidden = false
            subtitleLabel.reactive.text <~ input.producer
                .take(until: reactive.prepareForReuse)
        } else {
            subtitleLabel.isHidden = true
        }

        if let icon = viewModel.icon {
            iconView.isHidden = false
            iconView.image = icon
        } else {
            iconView.isHidden = true
        }

        switch viewModel.inputTextAlignment {
        case .left, .center:
            titleLabelMinWidthConstraint.isActive = true
        case .right:
            titleLabelMinWidthConstraint.isActive = false
        }

        switch viewModel.iconStyle {
        case .miniature:
            largeRoundAvatarWidthConstraint.isActive = false
            NSLayoutConstraint.deactivate(largeRoundAvatarVerticalMarginConstraints)
            miniatureIconWidthConstraint.isActive = true
            iconView.layer.cornerRadius = 0.0
        case .largeRoundAvatar:
            miniatureIconWidthConstraint.isActive = false
            largeRoundAvatarWidthConstraint.isActive = true
            NSLayoutConstraint.activate(largeRoundAvatarVerticalMarginConstraints)
            iconView.layer.cornerRadius = largeRoundAvatarWidthConstraint.constant / 2.0
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if selected {
            becomeFirstResponder()
            resignFirstResponder()
            viewModel.isSelected.apply().start()
        }
    }
}
