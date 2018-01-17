import UIKit
import ReactiveSwift
import Result

open class FormCell: UITableViewCell {
    public final var isFormEnabled: Property<Bool> {
        return Property(capturing: _isFormEnabled)
    }

    public let isCellSelected: Signal<(), NoError>
    public var visibility: FormCellSeparatorVisibility = .invisible {
        didSet {
            switch visibility {
            case .invisible:
                separator.isHidden = true
            case .visible, .visibleNoInset:
                separator.isHidden = false
            }

            setNeedsUpdateConstraints()
        }
    }

    private let isCellSelectedObserver: Signal<(), NoError>.Observer

    private final var hasInitialized = false
    private final var _isFormEnabled = MutableProperty<Bool>(true)

    private let separator = UIView()

    private var separatorLeadingConstraint: NSLayoutConstraint!
    private var separatorInsetLeadingConstraint: NSLayoutConstraint!

    /// The preferred leading anchor which the separator should align its leading edge to,
    ///
    /// - note: If the cell is section defining or is the last in the section, this anchor
    ///         is ignored.
    internal var preferredSeparatorLeadingAnchor: NSLayoutXAxisAnchor {
        return leadingAnchor
    }

    /// The point height of the 1-pixel separator.
    internal final var separatorHeight: CGFloat {
        switch window?.screen.scale {
        case 2.0?, 3.0?:
            return 0.5
        default:
            return 1
        }
    }

    override public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        (isCellSelected, isCellSelectedObserver) = Signal.pipe()
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    public required init?(coder: NSCoder) {
        (isCellSelected, isCellSelectedObserver) = Signal.pipe()
        super.init(coder: coder)
    }

    override open func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    override open func updateConstraints() {
        if separatorLeadingConstraint == nil && separatorInsetLeadingConstraint == nil {
            separatorLeadingConstraint = separator.leadingAnchor.constraint(equalTo: leadingAnchor)
            separatorInsetLeadingConstraint = separator.leadingAnchor.constraint(equalTo: preferredSeparatorLeadingAnchor)

            NSLayoutConstraint.activate([
                separatorLeadingConstraint,
                // This is deliberately not `contentView.trailingAnchor` because
                // `contentView` shrinks when an accessory is present.
                separator.trailingAnchor.constraint(equalTo: trailingAnchor),
                separator.bottomAnchor.constraint(equalTo: bottomAnchor),
                separator.heightAnchor.constraint(equalToConstant: separatorHeight)
            ])
        }

        switch visibility {
        case .invisible:
            break
        case .visible:
            if separatorLeadingConstraint.isActive {
                separatorLeadingConstraint.isActive = false
                separatorInsetLeadingConstraint.isActive = true
            }
        case .visibleNoInset:
            if separatorInsetLeadingConstraint.isActive {
                separatorInsetLeadingConstraint.isActive = false
                separatorLeadingConstraint.isActive = true
            }
        }

        super.updateConstraints()
    }

    override open func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if selected {
            isCellSelectedObserver.send(value: ())
        }
    }

    internal final func configure(_ isFormEnabled: @autoclosure () -> Property<Bool>, _ separatorColor: UIColor) {
        if !hasInitialized {
            hasInitialized = true
            _isFormEnabled <~ isFormEnabled()
            separator.backgroundColor = separatorColor
        }
    }

    @nonobjc private func setup() {
        insertSubview(separator, aboveSubview: contentView)
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.isOpaque = true
    }

    deinit {
        isCellSelectedObserver.sendCompleted()
    }
}
