import UIKit

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
        borderWidth: CGFloat = 0
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
    }
    
    open func apply(to element: View) {
        element.backgroundColor = backgroundColor
        element.tintColor = tintColor
        element.clipsToBounds = clipsToBounds
        element.layer.cornerRadius = cornerRadius
        element.layer.masksToBounds = masksToBounds
        element.layer.borderColor = borderColor?.cgColor
        element.layer.borderWidth = borderWidth
        element.layoutMargins = layoutMargins
        element.transform = transform
    }
}
