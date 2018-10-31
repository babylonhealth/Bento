import Bento
import StyleSheets

extension Component {
    public final class ImageOrLabel: AutoRenderable, HeightCustomizing {
        public let configurator: (View) -> Void
        public let styleSheet: StyleSheet
        
        let imageOrLabel: ImageOrLabelView.Content
        let heightComputer: () -> CGFloat
        
        public init(
            imageOrLabel: ImageOrLabelView.Content = .none,
            styleSheet: StyleSheet
            ) {
            configurator = { view in
                view.imageOrLabel.content = imageOrLabel
            }
            heightComputer = { () -> CGFloat in
                let height: CGFloat
                if let size = styleSheet.imageOrLabel.fixedSize {
                    height = size.height
                } else {
                    switch imageOrLabel {
                    case let .image(image):
                        height = image.size.height
                            + styleSheet.imageOrLabel.layoutMargins.top
                            + styleSheet.imageOrLabel.layoutMargins.bottom
                    case let .text(text):
                        height = (text as NSString)
                            .size(withAttributes: [.font: styleSheet.imageOrLabel.label.font])
                            .height
                            .rounded(.up)
                    case .none:
                        height = 0
                    }
                }
                return height
            }
            self.imageOrLabel = imageOrLabel
            self.styleSheet = styleSheet
        }
        
        public static func == (lhs: Component.ImageOrLabel, rhs: Component.ImageOrLabel) -> Bool {
            return lhs.imageOrLabel == rhs.imageOrLabel
        }
        
        public func height(forWidth width: CGFloat, inheritedMargins: UIEdgeInsets) -> CGFloat {
            return heightComputer()
        }
        
        public func estimatedHeight(forWidth width: CGFloat, inheritedMargins: UIEdgeInsets) -> CGFloat {
            return heightComputer()
        }
    }
}

extension Component.ImageOrLabel {
    public final class View: BaseView {
        let imageOrLabel = ImageOrLabelView()
        let background = UIView()
        
        public override init(frame: CGRect) {
            super.init(frame: frame)
            setupLayout()
        }
        
        @available(*, unavailable)
        public required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func setupLayout() {
            background
                .add(to: self)
                .pinCenterX(to: self.centerXAnchor)
                .pinTop(to: self)
                .pinBottom(to: self)
            
            background.widthAnchor.constraint(equalTo: self.heightAnchor, multiplier: 1.0) .activated()
            
            imageOrLabel
                .add(to: self)
                .pinCenter(to: self)
        }
    }
}

extension Component.ImageOrLabel {
    public final class StyleSheet: ViewStyleSheet<View> {
        let imageOrLabel: ImageOrLabelView.StyleSheet
        let background: ViewStyleSheet<UIView>
        
        public init(imageOrLabel: ImageOrLabelView.StyleSheet = ImageOrLabelView.StyleSheet(),
                    background: ViewStyleSheet<UIView> = ViewStyleSheet()) {
            self.imageOrLabel = imageOrLabel
            self.background = background
        }
        
        public override func apply(to element: View) {
            super.apply(to: element)
            background.apply(to: element.background)
            imageOrLabel.apply(to: element.imageOrLabel)
        }
    }}
