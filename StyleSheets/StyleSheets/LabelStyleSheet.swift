import UIKit

open class LabelStyleSheet: ViewStyleSheet<UILabel>, TextBoundComputing {
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
        lineBreakMode: NSLineBreakMode = .byTruncatingTail
    ) {
        self.font = font
        self.textColor = textColor
        self.textAlignment = textAlignment
        self.numberOfLines = numberOfLines
        self.lineBreakMode = lineBreakMode
        
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
}
