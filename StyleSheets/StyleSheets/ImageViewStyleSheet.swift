import UIKit

open class ImageViewStyleSheet: ViewStyleSheet<UIImageView> {
    public var contentMode: UIView.ContentMode
    
    public init(
        contentMode: UIView.ContentMode = .scaleAspectFit
        ) {
        self.contentMode = contentMode
    }
    
    open override func apply(to element: UIImageView) {
        super.apply(to: element)
        
        element.contentMode = contentMode
    }
}
