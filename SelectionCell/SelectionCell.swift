import UIKit
import ReactiveSwift
import ReactiveCocoa
import Result

open class SelectionCell: FormItemCell, NibLoadableCell {
    enum Style {
        case rightTick
        case leftTickWithDetailDisclosure
    }

    @IBOutlet var avatarLeading: NSLayoutConstraint!
    @IBInspectable var avatarLeadingInsetNoLeftTick: CGFloat = 0.0
    @IBInspectable var avatarLeadingInsetWithLeftTick: CGFloat = 0.0

    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var disclosure: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var leftTick: UIImageView!
    @IBOutlet weak var rightTick: UIImageView!

    private let disposable = SerialDisposable()
    private var spec: SelectionCellViewSpec!

    private var style: Style!

    override open var preferredSeparatorLeadingAnchor: NSLayoutXAxisAnchor {
        return label.leadingAnchor
    }

    override open func awakeFromNib() {
        super.awakeFromNib()

        style = .rightTick
        avatar.layer.masksToBounds = true
        activityIndicator.isHidden = true
    }

    override open func layoutSubviews() {
        super.layoutSubviews()
        avatar.layer.cornerRadius = avatar.frame.size.width / 2.0
    }

    func configure(for viewModel: SelectionCellViewModel, in group: SelectionCellGroupViewModel, spec: SelectionCellViewSpec) {
        disposable.inner = nil
        self.spec = spec

        avatar.reactive.image
            <~ viewModel.icon
                .take(until: reactive.prepareForReuse)
                .prefix(value: spec.defaultIcon)

        label.text = viewModel.title
        spec.labelStyle?.apply(to: label)

        style = group.hasDisclosureAction ? .leftTickWithDetailDisclosure : .rightTick

        // Both are hidden initially.
        leftTick.isHidden = true
        rightTick.isHidden = true

        switch style! {
        case .leftTickWithDetailDisclosure:
            leftTick.image = spec.tick
            leftTick.tintColor = spec.tickColor
            disclosure.isHidden = false
            avatarLeading.constant = avatarLeadingInsetWithLeftTick

        case .rightTick:
            rightTick.image = spec.tick
            rightTick.tintColor = spec.tickColor
            disclosure.isHidden = true
            avatarLeading.constant = avatarLeadingInsetNoLeftTick
        }

        let d = CompositeDisposable()

        d += group
            .controlAvailability(for: viewModel.identifier, isFormEnabled: isFormEnabled)
            .startWithValues { [weak self] in self?.update(for: $0) }

        d += group.selected(forItemIdentifier: viewModel.identifier)
            <~ isCellSelected

        d += group.disclosureButtonPressed(forItemIdentifier: viewModel.identifier)
            <~ disclosure.reactive
                .controlEvents(.primaryActionTriggered)
                .discardValues()

        disposable.inner = d
    }

    private func update(for status: SelectionCellStatus) {
        switch status {
        case let .disabled(selected):
            isUserInteractionEnabled = false
            activityIndicator.isHidden = true
            disclosure.isHidden = style == .rightTick
            disclosure.isEnabled = false
            configureTick(isSelected: selected, isEnabled: false, isProcessing: false)
            accessoryType = spec.accessoryType

        case let .enabled(selected, isDisclosureEnabled):
            isUserInteractionEnabled = true
            activityIndicator.isHidden = true
            disclosure.isHidden = style == .rightTick
            disclosure.isEnabled = isDisclosureEnabled
            configureTick(isSelected: selected, isEnabled: true, isProcessing: false)
            accessoryType = spec.accessoryType

        case let .processing(selected):
            isUserInteractionEnabled = false
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
            disclosure.isHidden = true
            configureTick(isSelected: selected, isEnabled: false, isProcessing: true)
            accessoryType = .none
        }
    }

    private func configureTick(isSelected: Bool, isEnabled: Bool, isProcessing: Bool) {
        switch style! {
        case .leftTickWithDetailDisclosure:
            leftTick.isHidden = !isSelected
            leftTick.tintColor = isEnabled ? spec.tickColor : spec.disabledTickColor

        case .rightTick:
            rightTick.isHidden = !(!isProcessing && isSelected)
            rightTick.tintColor = isEnabled ? spec.tickColor : spec.disabledTickColor
        }
    }
}
