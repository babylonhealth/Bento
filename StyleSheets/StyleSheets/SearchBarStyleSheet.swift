import UIKit

open class SearchBarStyleSheet: ViewStyleSheet<UISearchBar> {
    public var textInputBackgroundColor: UIColor = .white
    public var textInputCornerRaidus: CGFloat = 10
    public var height: CGFloat = 36
    public var searchTextPositionAdjustment: UIOffset = UIOffset(horizontal: 8, vertical: 0)
    public var keyboardType: UIKeyboardType = .default
    public var returnKeyType: UIReturnKeyType = .search
    public var enablesReturnKeyAutomatically: Bool = true

    open override func apply(to element: UISearchBar) {
        super.apply(to: element)
        element.setTextInputBackgroundColor(color: textInputBackgroundColor,
                                            height: height,
                                            cornerRadius: textInputCornerRaidus)
        element.searchTextPositionAdjustment = searchTextPositionAdjustment
        element.keyboardType = keyboardType
        element.returnKeyType = returnKeyType
        element.enablesReturnKeyAutomatically = enablesReturnKeyAutomatically
        element.barTintColor = tintColor
        // remove system background
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
