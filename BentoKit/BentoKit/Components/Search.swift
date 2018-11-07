import Bento
import StyleSheets

extension Component {
    public final class Search: AutoRenderable {
        public let configurator: (View) -> Void
        public let styleSheet: StyleSheet

        public init(
            placeholder: String? = nil,
            keyboardType: UIKeyboardType = .default,
            textDidChange: Optional<(String) -> Void> = nil,
            cancelButtonClicked: Optional<() -> Void> = nil,
            styleSheet: StyleSheet
            ) {
            self.configurator = { view in
                view.searchBar.placeholder = placeholder
                view.searchBar.keyboardType = keyboardType
                view.textDidChange = textDidChange
                view.cancelButtonClicked = cancelButtonClicked
            }
            self.styleSheet = styleSheet
        }
    }
}

extension Component.Search {
    public final class View: BaseView, UISearchBarDelegate {

        fileprivate let searchBar = UISearchBar()

        var textDidChange: Optional<(String) -> Void> = nil
        var cancelButtonClicked: Optional<() -> Void> = nil
        var didBeginEditing: Optional<() -> Void> = nil

        public override init(frame: CGRect) {
            super.init(frame: frame)

            searchBar.add(to: self)
                .height(36)
                .pinEdges(to: layoutMarginsGuide)
            searchBar.backgroundColor = .white
            searchBar.barTintColor = .white
            searchBar.backgroundImage = UIImage()
            searchBar.delegate = self
        }

        @available(*, unavailable)
        public required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        public func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
            self.didBeginEditing?()
        }

        public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            searchBar.endEditing(true)
        }

        public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            self.textDidChange?(searchText)
        }

        public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            self.cancelButtonClicked?()
        }
    }
}

extension Component.Search {
    public final class StyleSheet: BaseViewStyleSheet<View> {
        public struct SearchBar: StyleSheetProtocol {
            public var backgroundColor: UIColor = .white
            public var cornerRadius: CGFloat = 10
            public var height: CGFloat = 36
            public var showsCancelButton: Bool = false
            public var searchTextPositionAdjustment: UIOffset = UIOffset.init(horizontal: 8, vertical: 0)
            public var keyboardType: UIKeyboardType = .default
            public var returnKeyType: UIReturnKeyType = .search
            public var enablesReturnKeyAutomatically: Bool = true

            public func apply(to element: UISearchBar) {
                element.setTextInputBackgroundColor(color: backgroundColor,
                                                    height: height,
                                                    cornerRadius: cornerRadius)
                element.showsCancelButton = showsCancelButton
                element.searchTextPositionAdjustment = searchTextPositionAdjustment
                element.keyboardType = keyboardType
                element.returnKeyType = returnKeyType
                element.enablesReturnKeyAutomatically = enablesReturnKeyAutomatically
            }
        }
        public var searchBar: SearchBar = SearchBar()

        public init() {}

        public override func apply(to element: View) {
            super.apply(to: element)
            searchBar.apply(to: element.searchBar)
        }
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
