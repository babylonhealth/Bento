import UIKit
import ReactiveSwift
import ReactiveCocoa
import Result

open class SelectionCell: FormCell, NibLoadableCell {
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

        avatar.image = viewModel.icon ?? spec.defaultIcon
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

        case let .enabled(selected, isDisclosureEnabled):
            isUserInteractionEnabled = true
            activityIndicator.isHidden = true
            disclosure.isHidden = style == .rightTick
            disclosure.isEnabled = isDisclosureEnabled
            configureTick(isSelected: selected, isEnabled: true, isProcessing: false)

        case let .processing(selected):
            isUserInteractionEnabled = false
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
            disclosure.isHidden = true
            configureTick(isSelected: selected, isEnabled: false, isProcessing: true)
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
