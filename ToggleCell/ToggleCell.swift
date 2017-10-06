import ReactiveSwift
import ReactiveCocoa

extension ToggleCell: NibLoadableCell {}

class ToggleCell: FormItemCell {
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var toggle: UISwitch!

    @IBOutlet weak var iconWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var iconLabelSpacingConstraint: NSLayoutConstraint!

    var viewModel: ToggleCellViewModel!

    override var preferredSeparatorLeadingAnchor: NSLayoutXAxisAnchor {
        return titleLabel.leadingAnchor
    }

    func setup(viewModel: ToggleCellViewModel) {
        self.viewModel = viewModel

        titleLabel.text = viewModel.title
        viewModel.applyTitleStyle(to: titleLabel)

        toggle.reactive.isEnabled <~ viewModel.isEnabled.and(isFormEnabled).producer
            .take(until: reactive.prepareForReuse)

        toggle.isOn = viewModel.isOn.value

        viewModel.isOn <~ toggle.reactive.isOnValues
            .take(until: reactive.prepareForReuse)

        switch viewModel.icon {
        case let .some(image):
            iconView.image = image
            iconWidthConstraint.constant = 32
            iconLabelSpacingConstraint.constant = 8
        case .none:
            iconView.image = nil
            iconWidthConstraint.constant = 0
            iconLabelSpacingConstraint.constant = 0
        }
    }
}
