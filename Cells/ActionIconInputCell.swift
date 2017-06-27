import UIKit
import ReactiveSwift

extension ActionIconInputCell: NibLoadableCell {}

final class ActionIconInputCell: UITableViewCell {

    private var viewModel: ActionIconInputCellViewModel!

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var input: UILabel!
    @IBOutlet weak var inputTrailing: NSLayoutConstraint!
    @IBOutlet weak var icon: UIImageView!

    func setup(viewModel: ActionIconInputCellViewModel) {
        self.viewModel = viewModel
        self.selectionStyle = self.viewModel.selectionStyle
        viewModel.applyTitleStyle(to: title)
        viewModel.applyInputStyle(to: input)
        title.text = viewModel.title
        accessoryType = viewModel.accessory
        inputTrailing.constant = accessoryType == .none ? 16 : 0
        icon.image = viewModel.icon 
        
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
