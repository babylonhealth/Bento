import UIKit

open class TextViewStyleSheet: TextStyleSheet<UITextView> {
    public var isEditable = true
    public var isScrollEnabled = true
    public var isSelectable = true
    public var textContainerInset = UIEdgeInsets(top: 8.0, left: 0.0, bottom: 8.0, right: 0.0)
    public var linkTextAttributes: [NSAttributedString.Key : Any]? = nil

    open override func apply(to element: UITextView) {
        super.apply(to: element)
        element.isEditable = isEditable
        element.isScrollEnabled = isScrollEnabled
        element.isSelectable = isSelectable
        element.textContainerInset = textContainerInset
        element.linkTextAttributes = linkTextAttributes
    }
}
