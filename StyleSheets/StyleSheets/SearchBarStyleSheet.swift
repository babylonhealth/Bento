import UIKit

open class SearchBarStyleSheet: ViewStyleSheet<UISearchBar> {
    public var height: CGFloat
    public var showsCancelButton: Bool
    public var searchTextPositionAdjustment: UIOffset
    public var keyboardType: UIKeyboardType
    public var returnKeyType: UIReturnKeyType
    public var enablesReturnKeyAutomatically: Bool

    public init(
        backgroundColor: UIColor = .white,
        cornerRadius: CGFloat = 10,
        height: CGFloat = 36,
        showsCancelButton: Bool = false,
        searchTextPositionAdjustment: UIOffset = UIOffset(horizontal: 8, vertical: 0),
        keyboardType: UIKeyboardType = .default,
        returnKeyType: UIReturnKeyType = .search,
        enablesReturnKeyAutomatically: Bool = true
        ) {
        self.height = height
        self.showsCancelButton = showsCancelButton
        self.searchTextPositionAdjustment = searchTextPositionAdjustment
        self.keyboardType = keyboardType
        self.returnKeyType = returnKeyType
        self.enablesReturnKeyAutomatically = enablesReturnKeyAutomatically
        super.init(backgroundColor: backgroundColor, cornerRadius: cornerRadius)
    }

    open override func apply(to element: UISearchBar) {
        super.apply(to: element)
        element.setTextInputBackgroundColor(color: backgroundColor ?? .clear,
                                            height: height,
                                            cornerRadius: cornerRadius)
        element.showsCancelButton = showsCancelButton
        element.searchTextPositionAdjustment = searchTextPositionAdjustment
        element.keyboardType = keyboardType
        element.returnKeyType = returnKeyType
        element.enablesReturnKeyAutomatically = enablesReturnKeyAutomatically
        element.barTintColor = tintColor
        // remove system background
        element.backgroundColor = .white
        element.backgroundImage = UIImage()
    }

}

extension UISearchBar {
    func setTextInputBackgroundColor(color: UIColor, height: CGFloat, cornerRadius: CGFloat) {
        // creates an image with rounded corners from background color
        let size = CGSize(width: cornerRadius * 2, height: height)
        let backgroundImage = UIGraphicsImageRenderer(size: size)
            .image { imageContext in
                let path = UIBezierPath(roundedRect: CGRect(origin: .zero, size: size), cornerRadius: cornerRadius)

                imageContext.cgContext.beginPath()
                imageContext.cgContext.addPath(path.cgPath)
                imageContext.cgContext.closePath()
                imageContext.cgContext.clip()

                imageContext.cgContext.setFillColor(color.cgColor)
                imageContext.cgContext.fill(CGRect(origin: .zero, size: size))
        }
        setSearchFieldBackgroundImage(backgroundImage, for: .normal)
    }
}
