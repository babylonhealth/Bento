import UIKit
import StyleSheets

public enum TextValue: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self = .plain(value)
    }

    case plain(String)
    case rich(NSAttributedString)

    public var isEmpty: Bool {
        switch self {
        case let .plain(text):
            return text.isEmpty
        case let .rich(text):
            // TODO: [WLT] (10/2018) need a better definition of empty for attributed strings
            return text.isEqual(to: NSAttributedString.init(string: ""))
        }
    }

    public var isNotEmpty: Bool {
        return isEmpty == false
    }

    public func apply(to label: UILabel) {
        switch self {
        case let .plain(text):
            label.text = text
        case let .rich(text):
            label.attributedText = text
        }
    }

    public func apply(to textField: UITextField) {
        switch self {
        case let .plain(text):
            textField.text = text
        case let .rich(text):
            textField.attributedText = text
        }
    }

    public func width(using styleSheet: LabelStyleSheet) -> CGFloat {
        switch self {
        case let .plain(text):
            return styleSheet.width(of: text)
        case let .rich(text):
            return styleSheet.width(of: text)
        }
    }

    public func height(using styleSheet: LabelStyleSheet,
                       fittingWidth width: CGFloat) -> CGFloat {
        switch self {
        case let .plain(text):
            return styleSheet.height(of: text, fittingWidth: width)
        case let .rich(text):
            return styleSheet.height(of: text, fittingWidth: width)
        }
    }
}
