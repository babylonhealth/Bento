import UIKit
import ReactiveSwift

extension ActionInputCell: NibLoadableCell {}

final class ActionInputCell: FormCell {

    private var viewModel: ActionInputCellViewModel!

    @IBOutlet weak var titleView: UILabel!
    @IBOutlet weak var subtitleView: UILabel!
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet var titleViewAlignment: NSLayoutConstraint!

    override var canBecomeFirstResponder: Bool {
        return true
    }

    func setup(viewModel: ActionInputCellViewModel) {
        self.viewModel = viewModel
        viewModel.applyTitleStyle(to: titleView)
        viewModel.applyInputStyle(to: subtitleView)
        iconView.image = viewModel.icon
        accessoryType = viewModel.accessory
        selectionStyle = self.viewModel.selectionStyle

        reactive.isUserInteractionEnabled <~ viewModel.isSelected.isEnabled.and(isFormEnabled).producer

        titleView.reactive.text <~ viewModel.title.producer
            .take(until: reactive.prepareForReuse)

        if let input = viewModel.input {
            subtitleView.isHidden = false
            subtitleView.reactive.text <~ input.producer
                .take(until: reactive.prepareForReuse)
        } else {
            subtitleView.isHidden = true
        }

        if let icon = viewModel.icon {
            iconView.isHidden = false
            iconView.image = icon
        } else {
            iconView.isHidden = true
        }

        switch viewModel.inputTextAlignment {
        case .left, .center:
            titleViewAlignment.isActive = true

        case .right:
            titleViewAlignment.isActive = false
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
