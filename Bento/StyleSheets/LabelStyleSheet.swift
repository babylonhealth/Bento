import UIKit

open class LabelStyleSheet: TextStyleSheet<UILabel>, TextBoundComputing {
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
        self.numberOfLines = numberOfLines
        self.lineBreakMode = lineBreakMode
        
        super.init(backgroundColor: backgroundColor, font: font, textColor: textColor, textAlignment: textAlignment)
    }
    
    open override func apply(to element: UILabel) {
        super.apply(to: element)
        
        element.numberOfLines = numberOfLines
        element.lineBreakMode = lineBreakMode
    }
}
