import ReactiveSwift
import ReactiveCocoa

extension ToggleCell: NibLoadableCell {}

class ToggleCell: FormItemCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var toggle: UISwitch!

    var viewModel: ToggleCellViewModel!

    override func awakeFromNib() {
        super.awakeFromNib()
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
    }
}
