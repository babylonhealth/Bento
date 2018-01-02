import UIKit
import ReactiveSwift
import ReactiveCocoa
import Result

open class LegacySelectionCell: FormItemCell, NibLoadableCell {
    private enum Style {
        case rightTick
        case leftTickWithDetailDisclosure
        case justDetailDisclosure
    }

    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var disclosure: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var leftTick: UIImageView!
    @IBOutlet weak var rightTick: UIImageView!

    @IBOutlet var avatarConstraints: [NSLayoutConstraint]!
    @IBOutlet var leftTickConstraints: [NSLayoutConstraint]!
    @IBOutlet var subtitleConstraints: [NSLayoutConstraint]!

    private let disposable = SerialDisposable()
    private var spec: LegacySelectionCellViewSpec!

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

    func configure(for viewModel: LegacySelectionCellViewModel, in group: LegacySelectionCellGroupViewModel, spec: LegacySelectionCellViewSpec) {
        disposable.inner = nil
        self.spec = spec

        switch viewModel.icon {
        case .some(let icon):
            NSLayoutConstraint.activate(avatarConstraints)
            avatar.reactive.image <~ icon.take(until: reactive.prepareForReuse)
        case .none:
            NSLayoutConstraint.deactivate(avatarConstraints)
            avatar.image = nil
        }

        label.text = viewModel.title
        spec.labelStyle?.apply(to: label)

        if let subtitle = viewModel.subtitle {
            subtitleLabel.text = subtitle
            spec.subtitleStyle?.apply(to: subtitleLabel)
            subtitleLabel.isHidden = false
            NSLayoutConstraint.activate(subtitleConstraints)
        } else {
            subtitleLabel.text = nil
            subtitleLabel.isHidden = true
            NSLayoutConstraint.deactivate(subtitleConstraints)
        }

        switch (group.hasDisclosureAction, spec.tick) {
        case (true, .some):
            style = .leftTickWithDetailDisclosure
        case (false, _):
            style = .rightTick
        case (true, .none):
            style = .justDetailDisclosure
        }

        // Both are hidden initially.
        leftTick.isHidden = true
        rightTick.isHidden = true

        switch style! {
        case .leftTickWithDetailDisclosure:
            leftTick.image = spec.tick
            leftTick.tintColor = spec.tickColor
            disclosure.isHidden = false
            NSLayoutConstraint.activate(leftTickConstraints)

        case .rightTick:
            rightTick.image = spec.tick
            rightTick.tintColor = spec.tickColor
            disclosure.isHidden = true
            NSLayoutConstraint.deactivate(leftTickConstraints)

        case .justDetailDisclosure:
            disclosure.isHidden = false
            NSLayoutConstraint.deactivate(leftTickConstraints)
        }

        let d = CompositeDisposable()

        d += group
            .controlAvailability(for: viewModel.identifier, isFormEnabled: isFormEnabled)
            .observe(on: UIScheduler())
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

        case .justDetailDisclosure:
            leftTick.isHidden = true
            rightTick.isHidden = true
        }
    }
}
