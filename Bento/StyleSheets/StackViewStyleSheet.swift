import UIKit

/// A stylesheet which can configure any instance of `UIStackView`.
///
/// `UIStackView` is a nonrendering subclass of `UIView` and because of that we cannot inherit from `ViewStyleSheet` due
/// the majority of the properties of a view cannot be applied to a stack view. This stylsheet focus in managing all the
/// configuration characteristic of any `UIStackView` which goes from the `axis` to `distribution` but also includes
/// some more general properties like `layoutMargins` and `clipsToBounds`.
open class StackViewStyleSheet<View: UIStackView>: StyleSheetProtocol {
    public var axis: NSLayoutConstraint.Axis
    public var spacing: CGFloat
    public var distribution: UIStackView.Distribution
    public var alignment: UIStackView.Alignment
    public var isBaselineRelativeArrangement : Bool
    public var isLayoutMarginsRelativeArrangement: Bool
    public var layoutMargins: UIEdgeInsets
    public var clipsToBounds: Bool
    
    public init(
        axis: NSLayoutConstraint.Axis,
        spacing: CGFloat,
        distribution: UIStackView.Distribution,
        alignment: UIStackView.Alignment,
        isBaselineRelativeArrangement : Bool = false,
        isLayoutMarginsRelativeArrangement: Bool = false,
        layoutMargins: UIEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8),
        clipsToBounds: Bool = false
    ) {
        self.axis = axis
        self.spacing = spacing
        self.distribution = distribution
        self.alignment = alignment
        self.isBaselineRelativeArrangement = isBaselineRelativeArrangement
        self.isLayoutMarginsRelativeArrangement = isLayoutMarginsRelativeArrangement
        self.layoutMargins = layoutMargins
        self.clipsToBounds = clipsToBounds
    }
    
    open func apply(to element: UIStackView) {
        element.axis = axis
        element.spacing = spacing
        element.distribution = distribution
        element.alignment = alignment
        element.isBaselineRelativeArrangement = isBaselineRelativeArrangement
        element.isLayoutMarginsRelativeArrangement = isLayoutMarginsRelativeArrangement
        element.layoutMargins = layoutMargins
        element.clipsToBounds = clipsToBounds
    }
}
