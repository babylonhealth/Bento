import UIKit
import Bento
import StyleSheets

extension Component {
    public final class EmptySpace: Renderable {
        private let height: CGFloat
        private let styleSheet: ViewStyleSheet<UIView>

        public init(height: CGFloat, styleSheet: ViewStyleSheet<UIView> = .init()) {
            self.height = height
            self.styleSheet = styleSheet
        }

        public func render(in view: View) {
            styleSheet.apply(to: view)
            view.heightConstraint.constant = height
        }
    }
}

extension Component.EmptySpace {
    public final class View: BaseView {
        internal private(set) lazy var heightConstraint = self.heightAnchor.constraint(equalToConstant: 0.0)
            .withPriority(.cellRequired)
            .activated()
    }
}
