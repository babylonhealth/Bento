import Bento
import StyleSheets

extension Component {
    public final class Image: AutoRenderable {
        public let styleSheet: StyleSheet
        public let configurator: (View) -> Void
        public let accessibilityIdentifier: String?
        public let accessoryViewAccessibilityIdentifier: String?

        public init(image: UIImage? = nil,
                    styleSheet: StyleSheet,
                    accessibilityIdentifier: String? = nil,
                    accessoryViewAccessibilityIdentifier: String? = nil,
                    didTapAccessory: (() -> Void)? = nil,
                    interactionBehavior: InteractionBehavior = .becomeFirstResponder) {
            configurator = { view in
                view.imageView.image = image
                view.didTapAccessory = didTapAccessory
                view.interactionBehavior = interactionBehavior
                view.accessoryButton.isHidden = didTapAccessory == nil
                view.imageView.accessibilityIdentifier = accessibilityIdentifier
                view.accessoryButton.accessibilityIdentifier = accessoryViewAccessibilityIdentifier
            }
            self.styleSheet = styleSheet
            self.accessibilityIdentifier = accessibilityIdentifier
            self.accessoryViewAccessibilityIdentifier = accessoryViewAccessibilityIdentifier
        }
    }
}

extension Component.Image {
    public final class View: BaseView {
        fileprivate let imageView = UIImageView()
        fileprivate let accessoryButton = UIButton(type: .custom)
        var didTapAccessory: (() -> Void)?
        fileprivate var interactionBehavior: InteractionBehavior = .becomeFirstResponder

        public override init(frame: CGRect) {
            super.init(frame: frame)
            accessoryButton.addTarget(self, action: #selector(accessoryButtonPressed), for: .primaryActionTriggered)
            setupLayout()
        }

        @available(*, unavailable)
        public required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        private func setupLayout() {
            stack(.horizontal, alignment: .center)(
                imageView
            )
            .add(to: self)
            .pinEdges(to: layoutMarginsGuide)

            accessoryButton.add(to: self)
                .width(44)
                .height(44)
                .pinCenterX(to: imageView.trailingAnchor)
                .pinCenterY(to: imageView.topAnchor)
        }

        @objc
        private func accessoryButtonPressed() {
            if interactionBehavior.contains(.becomeFirstResponder) {
                becomeFirstResponder()
            }

            didTapAccessory?()
        }
    }
}

extension Component.Image {
    public final class StyleSheet: ViewStyleSheet<View> {
        public let image = ImageViewStyleSheet()
        public let accessory: ButtonStyleSheet

        public init(image: ImageViewStyleSheet = ImageViewStyleSheet(),
                    accessory: ButtonStyleSheet = ButtonStyleSheet()) {
            self.accessory = accessory
            super.init()
        }

        public override func apply(to element: View) {
            super.apply(to: element)
            image.apply(to: element.imageView)
            accessory.apply(to: element.accessoryButton)
        }
    }
}
