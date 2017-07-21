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

    override public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        (isCellSelected, isCellSelectedObserver) = Signal.pipe()
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    public required init?(coder: NSCoder) {
        (isCellSelected, isCellSelectedObserver) = Signal.pipe()
        super.init(coder: coder)
    }

    internal final func configure(_ isFormEnabled: @autoclosure () -> Property<Bool>) {
        if !hasInitialized {
            hasInitialized = true
            _isFormEnabled <~ isFormEnabled()
        }
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
