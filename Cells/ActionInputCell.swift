import UIKit
import ReactiveSwift

extension ActionInputCell: NibLoadableCell {}

final class ActionInputCell: UITableViewCell {

    private var viewModel: ActionInputCellViewModel!

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var input: UILabel!
    @IBOutlet weak var inputTrailing: NSLayoutConstraint!

    func setup(viewModel: ActionInputCellViewModel) {
        self.viewModel = viewModel
        self.selectionStyle = self.viewModel.selectionStyle
        viewModel.applyTitleStyle(to: title)
        viewModel.applyInputStyle(to: input)
        title.text = viewModel.title
        accessoryType = viewModel.accessory
        inputTrailing.constant = accessoryType == .none ? 16 : 0

        viewModel.input.producer
            .observe(on: UIScheduler())
            .take(until: reactive.prepareForReuse)
            .startWithValues(handle)
    }

    private func handle(text: String) {
        input.text = text
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if selected {
            viewModel.isSelected.apply().start()
        }
    }
}
