import UIKit

open class FormItemCell: FormCell {
    /// 44pt * 44pt is the recommended minimum tappable area.
    ///
    /// Configurable in the future with form-wise styling.
    public let minimumHeight: CGFloat = 44

    private var heightConstraint: NSLayoutConstraint!

    override open func updateConstraints() {
        if heightConstraint == nil {
            heightConstraint = contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: minimumHeight)
            heightConstraint.priority = UILayoutPriority(UILayoutPriority.required.rawValue - 1)
            heightConstraint.isActive = true
        } else {
            heightConstraint.constant = minimumHeight
        }

        super.updateConstraints()
    }
}
