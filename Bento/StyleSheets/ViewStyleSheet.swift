import UIKit

/// Basic StyleSheet.
/// StyleSheets can be used to provide how components should look like.
/// Component should only takes data which reflects what is rendered.
/// StyleSheet's job is to provide how component's view should looks like.
open class ViewStyleSheet<View: UIView>: StyleSheetProtocol {
    
    // MARK: Visual Appearance
    
    public var backgroundColor: UIColor?
    public var tintColor: UIColor?
    public var clipsToBounds: Bool
    public var transform: CGAffineTransform
    public var cornerRadius: CGFloat
    public var masksToBounds: Bool
    public var borderColor: UIColor?
    public var borderWidth: CGFloat
    public var shadowColor: UIColor?
    public var shadowRadius: CGFloat
    public var shadowOffset: CGSize
    public var shadowOpacity: Float
    
    // MARK: Content Margins
    
    public var layoutMargins: UIEdgeInsets
    
    // MARK: Initialisers
    
    public init(
        backgroundColor: UIColor? = nil,
        tintColor: UIColor? = nil,
        clipsToBounds: Bool = false,
        layoutMargins: UIEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8),
        transform: CGAffineTransform = .identity,
        cornerRadius: CGFloat = 0.0,
        masksToBounds: Bool = false,
        borderColor: UIColor? = nil,
        borderWidth: CGFloat = 0,
        shadowColor: UIColor? = nil,
        shadowRadius: CGFloat = 0,
        shadowOffset: CGSize = .zero,
        shadowOpacity: Float = 0
    ) {
        self.backgroundColor = backgroundColor
        self.tintColor = tintColor
        self.clipsToBounds = clipsToBounds
        self.cornerRadius = cornerRadius
        self.layoutMargins = layoutMargins
        self.transform = transform
        self.cornerRadius = cornerRadius
        self.masksToBounds = masksToBounds
        self.borderColor = borderColor
        self.borderWidth = borderWidth
        self.shadowColor = shadowColor
        self.shadowRadius = shadowRadius
        self.shadowOffset = shadowOffset
        self.shadowOpacity = shadowOpacity
    }
    
    open func apply(to element: View) {
        element.backgroundColor = backgroundColor
        element.tintColor = tintColor
        element.clipsToBounds = clipsToBounds
        element.layer.cornerRadius = cornerRadius
        element.layer.masksToBounds = masksToBounds
        element.layer.borderColor = borderColor?.cgColor
        element.layer.borderWidth = borderWidth
        element.layer.shadowColor = shadowColor?.cgColor
        element.layer.shadowRadius = shadowRadius
        element.layer.shadowOffset = shadowOffset
        element.layer.shadowOpacity = shadowOpacity
        element.layoutMargins = layoutMargins
        element.transform = transform
    }
}
