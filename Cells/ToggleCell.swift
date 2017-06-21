import ReactiveSwift
import ReactiveCocoa

extension ToggleCell: NibLoadableCell {}

class ToggleCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var toggle: UISwitch!

    var viewModel: ToggleCellViewModel!

    func setup(viewModel: ToggleCellViewModel) {
        self.viewModel = viewModel

        titleLabel.text = viewModel.title
        viewModel.applyTitleStyle(to: titleLabel)
        
        toggle.isOn = viewModel.isOn.value

        viewModel.isOn
            <~ toggle.reactive.isOnValues
                .take(until: reactive.prepareForReuse)
    }
}
