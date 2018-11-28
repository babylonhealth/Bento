import UIKit

open class LabelStyleSheet: ViewStyleSheet<UILabel>, TextBoundComputing {
    private static let prototype = UILabel()
    public var font: UIFont
    public var textColor: UIColor
    public var textAlignment: TextAlignment
    public var numberOfLines: Int
    public var lineBreakMode: NSLineBreakMode
    
    public var textAttributes: [NSAttributedString.Key: Any] {
        return [
            .font: font,
            .paragraphStyle: NSMutableParagraphStyle()
                .with { $0.alignment = textAlignment.systemValue() }
        ]
    }

    public init(
        backgroundColor: UIColor? = .clear,
        font: UIFont = UIFont.preferredFont(forTextStyle: .body),
        textColor: UIColor = .black,
        textAlignment: TextAlignment = .leading,
        numberOfLines: Int = 0,
        lineBrealMode: NSLineBreakMode = .byTruncatingTail
    ) {
        self.font = font
        self.textColor = textColor
        self.textAlignment = textAlignment
        self.numberOfLines = numberOfLines
        self.lineBreakMode = lineBrealMode
        
        super.init(backgroundColor: backgroundColor)
    }
    
    open override func apply(to element: UILabel) {
        super.apply(to: element)
        
        element.font = font
        element.textColor = textColor
        element.textAlignment = textAlignment.systemValue(for: element.effectiveUserInterfaceLayoutDirection)
        element.numberOfLines = numberOfLines
        element.lineBreakMode = lineBreakMode
    }

    public func height(of string: NSAttributedString, fittingWidth width: CGFloat) -> CGFloat {
        apply(to: LabelStyleSheet.prototype)
        LabelStyleSheet.prototype.attributedText = string
        return LabelStyleSheet.prototype
            .systemLayoutSizeFitting(
                CGSize(width: width, height: UIView.layoutFittingCompressedSize.height),
                withHorizontalFittingPriority: .required,
                verticalFittingPriority: .defaultLow
            ).height
    }

    public func height(of string: String, fittingWidth width: CGFloat) -> CGFloat {
        apply(to: LabelStyleSheet.prototype)
        LabelStyleSheet.prototype.text = string as String
        return LabelStyleSheet.prototype
            .systemLayoutSizeFitting(
                CGSize(width: width, height: UIView.layoutFittingCompressedSize.height),
                withHorizontalFittingPriority: .required,
                verticalFittingPriority: .defaultLow
            )
            .height
    }
}
