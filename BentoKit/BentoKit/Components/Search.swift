import Bento
import StyleSheets

extension Component {
    public final class Search: AutoRenderable {
        public let configurator: (View) -> Void
        public let styleSheet: StyleSheet

        public init(
            placeholder: String? = nil,
            keyboardType: UIKeyboardType = .default,
            didBeginEditing: Optional<(UISearchBar) -> Void> = nil,
            textDidChange: Optional<(UISearchBar, String) -> Void> = nil,
            showsCancelButton: Bool = false,
            cancelButtonClicked: Optional<(UISearchBar) -> Void> = nil,
            styleSheet: StyleSheet = StyleSheet()
            ) {
            self.configurator = { view in
                view.searchBar.placeholder = placeholder
                view.searchBar.keyboardType = keyboardType
                view.didBeginEditing = didBeginEditing
                view.textDidChange = textDidChange
                view.cancelButtonClicked = cancelButtonClicked
                view.showsCancelButton = showsCancelButton
                view.searchBar.height(styleSheet.searchBar.height)
            }
            self.styleSheet = styleSheet
        }
    }
}

extension Component.Search {
    public final class View: BaseView, UISearchBarDelegate {

        let searchBar = UISearchBar()

        var textDidChange: Optional<(UISearchBar, String) -> Void> = nil

        var showsCancelButton: Bool = false {
            didSet {
                searchBar.setShowsCancelButton(showsCancelButton, animated: true)
            }
        }
        var cancelButtonClicked: Optional<(UISearchBar) -> Void> = nil

        var didBeginEditing: Optional<(UISearchBar) -> Void> = nil

        public override init(frame: CGRect) {
            super.init(frame: frame)

            searchBar.add(to: self)
                .pinEdges(to: layoutMarginsGuide)

            searchBar.delegate = self
        }

        @available(*, unavailable)
        public required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        public func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
            self.didBeginEditing?(searchBar)
        }

        public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            searchBar.endEditing(true)
        }

        public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            self.textDidChange?(searchBar, searchText)
        }

        public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            self.cancelButtonClicked?(searchBar)
        }
    }
}

extension Component.Search {
    public final class StyleSheet: BaseViewStyleSheet<View> {
        public let searchBar = SearchBarStyleSheet()

        public init() {}

        public override func apply(to element: View) {
            super.apply(to: element)
            searchBar.apply(to: element.searchBar)
        }
    }
}
