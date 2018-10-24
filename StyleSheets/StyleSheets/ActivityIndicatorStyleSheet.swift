import UIKit

open class ActivityIndicatorStyleSheet: ViewStyleSheet<UIActivityIndicatorView> {
    public var activityIndicatorViewStyle: UIActivityIndicatorView.Style
    
    public init(activityIndicatorViewStyle: UIActivityIndicatorView.Style = .gray) {
        self.activityIndicatorViewStyle = activityIndicatorViewStyle
        super.init()
    }
    
    open override func apply(to element: UIActivityIndicatorView) {
        super.apply(to: element)
        element.style = activityIndicatorViewStyle
    }
}
