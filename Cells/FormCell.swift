import UIKit
import ReactiveSwift
import Result

open class FormCell: UITableViewCell {
    public final var isFormEnabled: Property<Bool> {
        return Property(capturing: _isFormEnabled)
    }

    private final var hasInitialized = false
    private final var _isFormEnabled = MutableProperty<Bool>(true)

    internal final func configure(_ isFormEnabled: Property<Bool>) {
        if !hasInitialized {
            hasInitialized = true
            _isFormEnabled <~ isFormEnabled
        }
    }
}
