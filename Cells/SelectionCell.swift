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

    private let state = MutableProperty<(group: SelectionCellGroup, identifier: Int)?>(nil)
    private let isProcessing = MutableProperty(false)
    private var spec: SelectionCellViewSpec!

    private var style: Style! {
        didSet {
            let usesLeftTick = style == .leftTickWithDetailDisclosure
            disclosure.isHidden = !usesLeftTick
            avatarLeading.constant = usesLeftTick ? avatarLeadingInsetWithLeftTick : avatarLeadingInsetNoLeftTick
            leftTick.isHidden = true
            rightTick.isHidden = true
        }
    }

    func configure(for viewModel: SelectionCellViewModel, in group: SelectionCellGroup, spec: SelectionCellViewSpec) {
        self.spec = spec
        avatar.image = spec.defaultIcon

        label.text = viewModel.title
        avatar.image = viewModel.icon ?? avatar.image
        style = group.discloseDetails == nil ? .rightTick : .leftTickWithDetailDisclosure

        switch style! {
        case .leftTickWithDetailDisclosure:
            leftTick.image = spec.tick
            leftTick.tintColor = spec.tickColor
        case .rightTick:
            leftTick.image = spec.tick
            rightTick.tintColor = spec.tickColor
        }

        state.value = (group: group, identifier: viewModel.identifier)
    }

    private func update(isSelectedInGroup: Bool, isEnabled: Bool, isProcessing: Bool) {
        isUserInteractionEnabled = isEnabled
        disclosure.isEnabled = isEnabled
        disclosure.isHidden = isProcessing

        switch style! {
        case .leftTickWithDetailDisclosure:
            disclosure.isHidden = isProcessing
            leftTick.isHidden = !isSelectedInGroup
            leftTick.tintColor = !isEnabled ? spec.disabledTickColor : spec.tickColor

        case .rightTick:
            rightTick.isHidden = !(!isProcessing && isSelectedInGroup)
            rightTick.tintColor = !isEnabled ? spec.disabledTickColor : spec.tickColor
        }

        activityIndicator.isHidden = !isProcessing
        if isProcessing {
            activityIndicator.startAnimating()
        }
    }

    override open func awakeFromNib() {
        super.awakeFromNib()

        style = .rightTick
        avatar.layer.masksToBounds = true
        activityIndicator.isHidden = true

        disclosure.reactive
            .controlEvents(.primaryActionTriggered)
            .observeValues { [weak self] _ in
                if let (group, identifier) = self?.state.value {
                    group.discloseDetails?(identifier)
                        .on(starting: { [weak self] in self?.isProcessing.value = true },
                            terminated: { [weak self] in self?.isProcessing.value = false })
                        .start()
                }
            }

        SignalProducer
            .combineLatest(
                state.producer
                    .skipNil()
                    .flatMap(.latest) { group, identifier in
                        return group.selection.producer
                            .map { $0 == identifier }
                            .skipRepeats()
                            .combineLatest(with: group.isExecuting.producer)
                    },
                isProcessing.producer,
                isFormEnabled.producer)
            .producer
            .startWithValues { [weak self] arguments in
                let ((isSelectedInGroup, isExecuting), isProcessing, isFormEnabled) = arguments
                self?.update(isSelectedInGroup: isSelectedInGroup,
                             isEnabled: !isExecuting && isFormEnabled,
                             isProcessing: isProcessing)
            }
    }

    override open func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if selected, let (group, identifier) = state.value {
            group.userSelected(identifier)
                .on(starting: { [weak self] in self?.isProcessing.value = true },
                    terminated: { [weak self] in self?.isProcessing.value = false })
                .start()
        }
    }

    override open func layoutSubviews() {
        super.layoutSubviews()
        avatar.layer.cornerRadius = avatar.frame.size.width / 2.0
    }
}
