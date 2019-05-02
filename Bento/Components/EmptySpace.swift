import UIKit

extension Component {
    public final class EmptySpace: Renderable, HeightCustomizing {
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

        public func estimatedHeight(forWidth width: CGFloat, inheritedMargins: UIEdgeInsets) -> CGFloat {
            return max(height, 1.1)
        }

        public func height(forWidth width: CGFloat, inheritedMargins: UIEdgeInsets) -> CGFloat {
            return max(height, 1.1)
        }
    }
}

extension Component.EmptySpace {
    public final class View: BaseView {
        lazy var heightConstraint: NSLayoutConstraint = self.heightAnchor
            .constraint(equalToConstant: 0)
            .withPriority(.cellRequired)
            .activated()
    }
}
