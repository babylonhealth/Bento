import UIKit

public protocol TextBoundComputing {
    var textAttributes: [NSAttributedString.Key: Any] { get }
    var lineBreakMode: NSLineBreakMode { get }
    var numberOfLines: Int { get }

    func height(of string: String, fittingWidth width: CGFloat) -> CGFloat
    func height(of string: NSAttributedString, fittingWidth width: CGFloat) -> CGFloat
}

extension TextBoundComputing {
    
    public func width(of string: String) -> CGFloat {
        return width(of: string as NSString)
    }
    
    public func width(of string: NSAttributedString) -> CGFloat {
        return width(of: string.string as NSString)
    }
    
    public func width(of string: NSString) -> CGFloat {
        return string
            .size(withAttributes: textAttributes)
            .width
            .rounded(.up)
    }
    
    public func height(of string: String, fittingWidth width: CGFloat) -> CGFloat {
        let container = NSTextContainer(size: CGSize(width: width, height: .greatestFiniteMagnitude))
        container.lineBreakMode = lineBreakMode
        container.maximumNumberOfLines = numberOfLines
        container.lineFragmentPadding = 0

        let storage = NSTextStorage(string: string, attributes: textAttributes)

        let manager = NSLayoutManager()
        manager.addTextContainer(container)
        storage.addLayoutManager(manager)

        return manager.usedRect(for: container).height.rounded(.up)
    }
    
    public func height(of string: NSAttributedString, fittingWidth width: CGFloat) -> CGFloat {
        return height(of: string.string, fittingWidth: width)
    }
}
