import UIKit
import ReactiveSwift

extension ActionInputCell: NibLoadableCell {}

final class ActionInputCell: FormItemCell {
    private var viewModel: ActionInputCellViewModel!

    @IBOutlet var stackViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet var miniatureIconWidthConstraint: NSLayoutConstraint!
    @IBOutlet var largeRoundAvatarWidthConstraint: NSLayoutConstraint!
    @IBOutlet var largeRoundAvatarVerticalMarginConstraints: [NSLayoutConstraint]!
    @IBOutlet var stackView: UIStackView!

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
        accessoryType = viewModel.accessory
        selectionStyle = viewModel.selectionStyle

        reactive.isUserInteractionEnabled <~ viewModel.isSelected.isEnabled.and(isFormEnabled).producer

        titleLabel.reactive.text <~ viewModel.title.producer
            .take(until: reactive.prepareForReuse)

        if let input = viewModel.input {
            subtitleLabel.isHidden = false
            subtitleLabel.reactive.text <~ input.producer
                .observe(on: UIScheduler())
                .take(until: reactive.prepareForReuse)
        } else {
            subtitleLabel.isHidden = true
        }

        var activatingConstraints: [NSLayoutConstraint] = []
        var deactivatingConstraints: [NSLayoutConstraint] = []

        switch viewModel.inputTextAlignment {
        case .left, .center:
            activatingConstraints.append(titleLabelMinWidthConstraint)
        case .right:
            deactivatingConstraints.append(titleLabelMinWidthConstraint)
        }

        switch (viewModel.iconStyle, viewModel.icon) {
        case let (.largeRoundAvatar, icon?):
            deactivatingConstraints.append(miniatureIconWidthConstraint)
            activatingConstraints.append(largeRoundAvatarWidthConstraint)
            activatingConstraints.append(contentsOf: largeRoundAvatarVerticalMarginConstraints)

            iconView.layer.cornerRadius = largeRoundAvatarWidthConstraint.constant / 2.0
            stackViewLeadingConstraint.constant = largeRoundAvatarWidthConstraint.constant + stackView.spacing
            iconView.isHidden = false
            iconView.reactive.image <~ icon
                .observe(on: UIScheduler())
                .take(until: reactive.prepareForReuse)
        case let (_, icon):
            // The icon view still participates in Auto Layout even if it is hidden. So
            // if the icon is not present, the miniature style would be forced so that
            // the icon view can practically have no effect on the cell height.
            deactivatingConstraints.append(largeRoundAvatarWidthConstraint)
            deactivatingConstraints.append(contentsOf: largeRoundAvatarVerticalMarginConstraints)
            activatingConstraints.append(miniatureIconWidthConstraint)
            iconView.layer.cornerRadius = 0.0

            if let icon = icon {
                iconView.isHidden = false
                iconView.reactive.image <~ icon
                    .observe(on: UIScheduler())
                    .take(until: reactive.prepareForReuse)
                stackViewLeadingConstraint.constant = miniatureIconWidthConstraint.constant + stackView.spacing
            } else {
                iconView.isHidden = true
                stackViewLeadingConstraint.constant = 0
            }
        }
        
        NSLayoutConstraint.deactivate(deactivatingConstraints)
        NSLayoutConstraint.activate(activatingConstraints)
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
