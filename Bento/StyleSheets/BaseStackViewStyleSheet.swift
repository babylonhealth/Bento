import UIKit

open class BaseStackViewStyleSheet<View: BaseStackView>: StackViewStyleSheet<View> {
    public var backgroundColor: UIColor?
    public var borderColor: UIColor?
    public var cornerRadius: CGFloat
    public var borderWidth: CGFloat

    public init(
        axis: NSLayoutConstraint.Axis,
        spacing: CGFloat,
        distribution: UIStackView.Distribution,
        alignment: UIStackView.Alignment,
        backgroundColor: UIColor? = nil,
        borderColor: UIColor? = nil,
        cornerRadius: CGFloat = 0.0,
        borderWidth: CGFloat = 0.0
    ) {
        self.backgroundColor = backgroundColor
        self.borderColor = borderColor
        self.cornerRadius = cornerRadius
        self.borderWidth = borderWidth

        super.init(
            axis: axis,
            spacing: spacing,
            distribution: distribution,
            alignment: alignment
        )
    }

    open func apply(to element: BaseStackView) {
        super.apply(to: element)
        element.backgroundColor = backgroundColor
        element.cornerRadius = cornerRadius
        element.borderColor = borderColor?.cgColor
        element.borderWidth = borderWidth
    }
}
