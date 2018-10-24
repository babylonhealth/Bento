import UIKit

open class StackViewStyleSheet: ViewStyleSheet<UIStackView> {
    public var axis: NSLayoutConstraint.Axis
    public var spacing: CGFloat
    public var distribution: UIStackView.Distribution
    public var alignment: UIStackView.Alignment
    
    public init(
        axis: NSLayoutConstraint.Axis,
        spacing: CGFloat,
        distribution: UIStackView.Distribution,
        alignment: UIStackView.Alignment) {
        
        self.axis = axis
        self.spacing = spacing
        self.distribution = distribution
        self.alignment = alignment
        
        super.init()
    }
    
    open override func apply(to element: UIStackView) {
        super.apply(to: element)
        
        element.axis = axis
        element.spacing = spacing
        element.distribution = distribution
        element.alignment = alignment
    }
}
