import UIKit
import ReactiveSwift
import ReactiveCocoa
import Result

open class SelectionCell: FormItemCell, NibLoadableCell {
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var leftTick: UIImageView!
    @IBOutlet weak var rightTick: UIImageView!

    @IBOutlet var avatarConstraints: [NSLayoutConstraint]!
    @IBOutlet var leftTickConstraints: [NSLayoutConstraint]!
    @IBOutlet var subtitleConstraints: [NSLayoutConstraint]!

    private let disclosureButton = UIButton(type: .detailDisclosure)
    private var viewModel: SelectionCellViewModel!

    override open var preferredSeparatorLeadingAnchor: NSLayoutXAxisAnchor {
        return label.leadingAnchor
    }

    override open func awakeFromNib() {
        super.awakeFromNib()
        avatar.layer.masksToBounds = true
    }

    override open func prepareForReuse() {
        super.prepareForReuse()
        leftTick.image = nil
        rightTick.image = nil
    }

    override open func layoutSubviews() {
        super.layoutSubviews()
        avatar.layer.cornerRadius = avatar.frame.size.width / 2.0
    }

    func setup(viewModel: SelectionCellViewModel) {
        self.viewModel = viewModel

        label.font = UIFont.preferredFont(forTextStyle: .body)
        subtitleLabel.font = UIFont.preferredFont(forTextStyle: .body)
        label.textColor = viewModel.titleColor
        subtitleLabel.textColor = viewModel.subtitleColor

        switch viewModel.icon {
        case .some(let icon):
            NSLayoutConstraint.activate(avatarConstraints)
            avatar.reactive.image <~ icon.producer.take(until: reactive.prepareForReuse)
        case .none:
            NSLayoutConstraint.deactivate(avatarConstraints)
            avatar.image = nil
        }

        label.text = viewModel.title

        if let subtitle = viewModel.subtitle {
            subtitleLabel.text = subtitle
            subtitleLabel.isHidden = false
            NSLayoutConstraint.activate(subtitleConstraints)
        } else {
            subtitleLabel.text = nil
            subtitleLabel.isHidden = true
            NSLayoutConstraint.deactivate(subtitleConstraints)
        }

        // Both are hidden initially.
        leftTick.isHidden = true
        rightTick.isHidden = true

        switch viewModel.style {
        case .disclosureIndicator:
            NSLayoutConstraint.deactivate(leftTickConstraints)
            accessoryType = viewModel.showsActivityIndicator
                ? .none
                : .disclosureIndicator

        case let .checkmark(isChecked):
            let tickView: UIImageView

            if let discloseDetails = viewModel.discloseDetails {
                tickView = leftTick
                NSLayoutConstraint.activate(leftTickConstraints)
                disclosureButton.reactive.pressed = CocoaAction(discloseDetails)
            } else {
                tickView = rightTick
                NSLayoutConstraint.deactivate(leftTickConstraints)
                disclosureButton.reactive.pressed = nil
            }

            tickView.image = viewModel.checkmark
            tickView.isHidden = viewModel.showsActivityIndicator || isChecked.isFalse
        }

        if viewModel.showsActivityIndicator {
            let view = UIActivityIndicatorView(activityIndicatorStyle: .gray)
            view.startAnimating()
            accessoryView = view
        } else {
            accessoryView = viewModel.discloseDetails.isNotNil ? disclosureButton : nil
        }
    }

    open override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if selected {
            viewModel?.select?.apply().start()
        }
    }
}
