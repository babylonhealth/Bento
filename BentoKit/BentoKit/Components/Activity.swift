import Bento
import StyleSheets

extension Component {
    public final class Activity: Renderable {
        private let isLoading: Bool
        private let styleSheet: StyleSheet

        public init(isLoading: Bool, styleSheet: StyleSheet = .init()) {
            self.isLoading = isLoading
            self.styleSheet = styleSheet
        }

        public func render(in view: Component.Activity.View) {
            (isLoading ? view.activityIndicator.startAnimating : view.activityIndicator.stopAnimating)()
            styleSheet.apply(to: view)
        }
    }
}

extension Component.Activity {
    public final class View: BaseView {
        public let activityIndicator = UIActivityIndicatorView(style: .gray)
            .with {
                $0.hidesWhenStopped = true
            }

        public override init(frame: CGRect) {
            super.init(frame: frame)
            setupLayout()
        }
        
        @available(*, unavailable)
        public required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        private func setupLayout() {
            stack(.vertical, alignment: .center)(
                activityIndicator
            )
            .add(to: self)
            .pinEdges(to: layoutMarginsGuide)
        }
    }
}

extension Component.Activity {
    public final class StyleSheet: BaseViewStyleSheet<View> {
        public let activityIndicator: ActivityIndicatorStyleSheet

        public init(activityIndicator: ActivityIndicatorStyleSheet = .init()) {
            self.activityIndicator = activityIndicator
            super.init(enforcesMinimumHeight: false)
        }

        public override func apply(to element: Component.Activity.View) {
            super.apply(to: element)
            activityIndicator.apply(to: element.activityIndicator)
        }
    }
}
