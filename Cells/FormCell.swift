import UIKit
import ReactiveSwift
import Result

open class FormCell: UITableViewCell {
    public final var isFormEnabled: Property<Bool> {
        return Property(capturing: _isFormEnabled)
    }

    public let isCellSelected: Signal<(), NoError>
    private let isCellSelectedObserver: Signal<(), NoError>.Observer

    private final var hasInitialized = false
    private final var _isFormEnabled = MutableProperty<Bool>(true)

    internal let separator = UIView()

    // The point height of the 1-pixel separator.
    internal var separatorHeight: CGFloat {
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

    internal final func configure(_ isFormEnabled: @autoclosure () -> Property<Bool>, _ separatorColor: UIColor) {
        if !hasInitialized {
            hasInitialized = true
            _isFormEnabled <~ isFormEnabled()
            separator.backgroundColor = separatorColor
        }
    }

    override open func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    @nonobjc private func setup() {
        insertSubview(separator, aboveSubview: contentView)
        separator.isOpaque = true
    }

    override open func layoutSubviews() {
        super.layoutSubviews()
        let height = separatorHeight
        separator.frame = CGRect(x: 0, y: frame.height - height, width: frame.width, height: height)
    }

    override open func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if selected {
            isCellSelectedObserver.send(value: ())
        }
    }

    deinit {
        isCellSelectedObserver.sendCompleted()
    }
}
