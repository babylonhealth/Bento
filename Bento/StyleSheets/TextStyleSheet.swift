import UIKit

public protocol TextViewProtocol: AnyObject {
    var font: UIFont? { get set }
    var textColor: UIColor? { get set }
    var textAlignment: NSTextAlignment { get set }
}

public protocol TextViewConfiguratorProtocol: AnyObject {
    func set(font: UIFont, textColor: UIColor, textAlignment: TextAlignment)
}

extension TextViewConfiguratorProtocol where Self: TextViewProtocol, Self: UIView {

    public func set(font: UIFont, textColor: UIColor, textAlignment: TextAlignment) {
        self.font = font
        self.textColor = textColor
        self.textAlignment = textAlignment.systemValue(for: self.effectiveUserInterfaceLayoutDirection)
    }
}

extension UITextField: TextViewProtocol & TextViewConfiguratorProtocol {}
extension UITextView: TextViewProtocol & TextViewConfiguratorProtocol {}

extension UILabel: TextViewConfiguratorProtocol {

    public func set(font: UIFont, textColor: UIColor, textAlignment: TextAlignment) {
        self.font = font
        self.textColor = textColor
        self.textAlignment = textAlignment.systemValue(for: self.effectiveUserInterfaceLayoutDirection)
    }
}

open class TextStyleSheet<T: UIView & TextViewConfiguratorProtocol>: ViewStyleSheet<T> {
    public var font: UIFont
    public var textColor: UIColor
    public var textAlignment: TextAlignment

    public init(
        backgroundColor: UIColor? = nil,
        font: UIFont = UIFont.preferredFont(forTextStyle: .body),
        textColor: UIColor = .black,
        textAlignment: TextAlignment = .leading
    ) {
        self.font = font
        self.textColor = textColor
        self.textAlignment = textAlignment
        super.init(backgroundColor: backgroundColor)
    }

    open override func apply(to element: T) {
        super.apply(to: element)

        element.set(font: font, textColor: textColor, textAlignment: textAlignment)
    }
}

open class TextFieldStylesheet: TextStyleSheet<UITextField> {
    public var borderStyle: UITextField.BorderStyle = .none
    public var isSecureTextEntry: Bool = false
    public var clearButtonMode: UITextField.ViewMode = .never

    open override func apply(to element: UITextField) {
        super.apply(to: element)
        element.borderStyle = borderStyle
        element.isSecureTextEntry = isSecureTextEntry
        element.clearButtonMode = clearButtonMode
    }
}
