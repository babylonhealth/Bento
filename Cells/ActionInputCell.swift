import UIKit
import ReactiveSwift

extension ActionInputCell: NibLoadableCell {}

final class ActionInputCell: FormCell {

    private var viewModel: ActionInputCellViewModel!

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var input: UILabel!
    @IBOutlet weak var inputTrailing: NSLayoutConstraint!

    override var canBecomeFirstResponder: Bool {
        return true
    }

    func setup(viewModel: ActionInputCellViewModel) {
        self.viewModel = viewModel
        self.selectionStyle = self.viewModel.selectionStyle
        viewModel.applyTitleStyle(to: title)
        viewModel.applyInputStyle(to: input)
        title.text = viewModel.title
        accessoryType = viewModel.accessory
        inputTrailing.constant = accessoryType == .none ? 16 : 0

        reactive.isUserInteractionEnabled <~ viewModel.isSelected.isEnabled.and(isFormEnabled).producer
            .take(until: reactive.prepareForReuse)

        input.reactive.text <~ viewModel.input.producer
            .take(until: reactive.prepareForReuse)

        isUserInteractionEnabled = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if selected {
            // Steal the first responder to dismiss the active input view.
            becomeFirstResponder()
            resignFirstResponder()

            viewModel.isSelected.apply().start()
        }
    }
}
