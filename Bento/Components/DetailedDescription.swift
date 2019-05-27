private let maxImageWidth: CGFloat = 100

public extension Component {
    /// `DetailedDescription` supports a horizontal layout comprising:
    ///
    /// (1) [Optional] an image or a text placeholder, at most 100 points in width,
    ///     with an optional badge icon whose position is customisable;
    /// (2) [Optional] a vertical stack of zero or more independent text labels;
    /// (3) [Optional] a single-line detail label; and
    /// (4) [Optional] an accessory.
    ///
    /// While `DetailedDescription` supports asynchronous loading for its image
    /// view, you are obligated to ensure a consistent fixed size across all
    /// changes.
    final class DetailedDescription: AutoRenderable {
        public typealias Accessory = AccessoryView.Accessory

        public let configurator: (View) -> Void
        public let styleSheet: StyleSheet

        /// Creates a DetailedDescription
        /// - parameter texts: Array of TextValues which are displayed vertically on left side of the row.
        /// - parameter detail: Description field displayed to the right of `texts`
        /// - parameter image: Usually an image wrapped within `ImageOrLabel` component. Property makes it possible to be loaded async.
        ///                    However, you need to guarantee fixed size across all changes.
        /// - parameter accessory: Accessory which should be displayed near the right edge of the row.
        /// - parameter badgeIcon: Badge icon which is displayed in the bottom-right corner of the `image`.
        /// - parameter didTap: Closure which is invoked when whole row is tapped.
        /// - parameter didTapAccessory: Closure which is invoked when tapping on the accessory.
        /// - parameter interactionBehavior: Defines an behaviour when tapped. Usually `.becomeFirstResponder`.
        /// - parameter styleSheet: StyleSheet how view should be styled (fonts, colors, text alignment)
        public init(
            texts: [TextValue] = [],
            detail: TextValue? = nil,
            image: Bento.ImageOrLabel? = nil,
            accessory: Accessory = .chevron,
            badgeIcon: UIImage? = nil,
            didTap: (() -> Void)? = nil,
            didTapAccessory: (() -> Void)? = nil,
            interactionBehavior: InteractionBehavior = .becomeFirstResponder,
            styleSheet: StyleSheet = .init()
        ) {
            self.configurator = { view in
                view.labels.forEach { $0.isHidden = true }
                zip(view.labels, texts).forEach { label, text in
                    text.apply(to: label)
                    label.isHidden = text.isEmpty
                }

                detail?.apply(to: view.detailLabel)
                view.detailLabel.isHidden = detail?.isEmpty ?? true

                if let image = image {
                    view.imageOrLabelView.content = image
                }
                view.imageOrLabelView.isHidden = image == nil

                view.accessoryView.accessory = accessory
                view.accessoryView.didTap = didTapAccessory
                view.accessoryView.interactionBehavior = interactionBehavior

                view.badgeView.imageView.image = badgeIcon
                view.badgeView.isHidden = badgeIcon == nil

                view.highlightingGesture.interactionBehavior = interactionBehavior
                view.highlightingGesture.didTap = didTap.map(HighlightingGesture.TapAction.resign)
                view.highlightingGesture.didRebindView()
            }

            self.styleSheet = styleSheet
        }
    }
}

extension Component.DetailedDescription {

    @objc(DetailedDescriptionView)
    public final class View: InteractiveView {

        var numberOfLabels: Int = 2 {
            didSet {
                guard numberOfLabels != oldValue else { return }
                processChangeInLabelCount()
            }
        }

        override init(frame: CGRect) {
            self.labels = (0 ..< numberOfLabels).map { _ in UILabel() }
            self.labelsContainer = stack(.vertical,
                                         spacing: 8.0,
                                         distribution: .fill,
                                         alignment: .fill,
                                         views: labels)

            super.init(frame: frame)
            contentStackView.add(to: self).pinEdges(to: layoutMarginsGuide)

            contentStackView.axis = .horizontal
            contentStackView.spacing = 8.0
            contentStackView.distribution = .fill
            contentStackView.alignment = .center

            contentStackView.addArrangedSubview(imageOrLabelView)
            contentStackView.addArrangedSubview(labelsContainer)
            contentStackView.addArrangedSubview(detailLabel)
            contentStackView.addArrangedSubview(accessoryView)

            [imageOrLabelView, labelsContainer, detailLabel, accessoryView].forEach {
                $0.translatesAutoresizingMaskIntoConstraints = false
            }

            imageOrLabelView.setContentHuggingPriority(.required, for: .horizontal)
            imageOrLabelView.setContentHuggingPriority(.required, for: .vertical)
            imageOrLabelView.setContentCompressionResistancePriority(.cellRequired, for: .vertical)
            imageOrLabelView.setContentCompressionResistancePriority(.required, for: .horizontal)

            labels.forEach { label in setupAutoLayoutPriorities(for: label)}

            detailLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
            detailLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
            detailLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
            detailLabel.setContentCompressionResistancePriority(.cellRequired, for: .vertical)

            addSubview(badgeView)
        }

        @available(*, unavailable)
        required init(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        fileprivate let contentStackView = BaseStackView()
        fileprivate let imageOrLabelView = ImageOrLabelView()
        fileprivate let labelsContainer: UIStackView
        fileprivate let detailLabel = UILabel()
        fileprivate let badgeView = BadgeView(frame: .zero)
        fileprivate let accessoryView = AccessoryView()

        fileprivate var labels: [UILabel]

        fileprivate lazy var badgeCenterYOffset = badgeView.centerYAnchor
            .constraint(equalTo: imageOrLabelView.bottomAnchor)
            .activated()

        fileprivate lazy var badgeCenterXOffset = badgeView.centerXAnchor
            .constraint(equalTo: imageOrLabelView.trailingAnchor)
            .activated()

        fileprivate var textBlockWidthFraction: CGFloat? {
            didSet {
                guard textBlockWidthFraction != oldValue else { return }
                textBlockWidthFractionDidChange()
            }
        }

        private var textBlockWidthConstraint: NSLayoutConstraint?
    }
}

extension Component.DetailedDescription.View: PreSizingLayoutPassRequiring {}

fileprivate extension Component.DetailedDescription.View {

    final class BadgeView: UIView {

        let imageView = UIImageView()

        lazy var width = widthAnchor
            .constraint(equalToConstant: 0)
            .activated()

        lazy var height = heightAnchor
            .constraint(equalToConstant: 0)
            .activated()

        override init(frame: CGRect) {
            super.init(frame: frame)
            setupLayout()
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        private func setupLayout() {
            translatesAutoresizingMaskIntoConstraints = false
            imageView.add(to: self).pinEdges(to: self)
        }
    }
}

private extension Component.DetailedDescription.View {
    func textBlockWidthFractionDidChange() {
        textBlockWidthConstraint?.isActive = false
        textBlockWidthConstraint = nil

        guard let fraction = textBlockWidthFraction else { return }
        textBlockWidthConstraint = labelsContainer.widthAnchor
            .constraint(equalTo: layoutMarginsGuide.widthAnchor, multiplier: fraction)
            .activated()
    }

    func processChangeInLabelCount() {
        let currentLabelCount = labels.count
        let newLabelCount = numberOfLabels
        let labelCountDifference = abs(newLabelCount - currentLabelCount)

        guard newLabelCount != currentLabelCount else { return }

        if newLabelCount > currentLabelCount {
            let labelsToAdd = (1 ... labelCountDifference).map { _ in UILabel() }
            labelsToAdd.forEach { label in
                setupAutoLayoutPriorities(for: label)
                labelsContainer.addArrangedSubview(label)
            }
            labels += labelsToAdd
        } else {
            let labelsToRemove = labels.suffix(labelCountDifference)
            labelsToRemove.forEach { $0.removeFromSuperview() }
            labels = [UILabel](labels.prefix(newLabelCount))
        }
    }

    func setupAutoLayoutPriorities(for label: UILabel) {
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentHuggingPriority(.required, for: .vertical)
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
    }
}

public extension Component.DetailedDescription {
    final class ContentStyleSheet: ViewStyleSheet<BaseStackView> {
        public typealias Alignment = UIStackView.Alignment

        public var spacing: CGFloat
        public var alignment: Alignment
        public var isLayoutMarginsRelativeArrangement: Bool

        public init(
            spacing: CGFloat = 16,
            alignment: Alignment = .center,
            isLayoutMarginsRelativeArrangement: Bool = false
            ) {
            self.spacing = spacing
            self.alignment = alignment
            self.isLayoutMarginsRelativeArrangement = isLayoutMarginsRelativeArrangement
        }

        public override func apply(to element: BaseStackView) {
            super.apply(to: element)
            element.spacing = spacing
            element.alignment = alignment
            element.isLayoutMarginsRelativeArrangement = isLayoutMarginsRelativeArrangement
            element.cornerRadius = cornerRadius
            element.borderColor = borderColor?.cgColor
            element.borderWidth = borderWidth
        }
    }

    final class StyleSheet: InteractiveViewStyleSheet<View> {

        public enum HighlightingTarget {
            case container
            case content
        }

        public var verticalSpacingBetweenElements: CGFloat
        public var textBlockWidthFraction: CGFloat?
        public var highlightingTarget: HighlightingTarget
        public var badgeOffset: CGPoint
        public var badgeSize: CGSize

        public let content: ContentStyleSheet
        public let imageOrLabel: ImageOrLabelView.StyleSheet
        public private(set) var textStyles: [LabelStyleSheet] // [WLT] Oct-11-2018 Change to 'public let' when legacy code is removed.
        /// Note that the detail label will be forced to have a single line so the
        /// `numberOfLines` parameter of `LabelStyleSheet` is ignored.
        public let detail: LabelStyleSheet
        public let badge: ViewStyleSheet<UIView>
        public let accessory: InteractiveViewStyleSheet<InteractiveView>

        public init(
            verticalSpacingBetweenElements: CGFloat = 8.0,
            textBlockWidthFraction: CGFloat? = nil,
            highlightingTarget: HighlightingTarget = HighlightingTarget.container,
            badgeOffset: CGPoint = .zero,
            badgeSize: CGSize = CGSize(width: 12, height: 12),
            enforcesMinimumHeight: Bool = true,
            content: ContentStyleSheet = .init(),
            imageOrLabel: ImageOrLabelView.StyleSheet = .init(),
            textStyles: [LabelStyleSheet] = [
            .init(),
            .init(font: UIFont.preferredFont(forTextStyle: .footnote),
                  textColor: .gray)
            ],
            detail: LabelStyleSheet = .init(textAlignment: .trailing),
            badge: ViewStyleSheet<UIView> = ViewStyleSheet<UIView>(),
            accessory: InteractiveViewStyleSheet<InteractiveView> = InteractiveViewStyleSheet<InteractiveView>()
            ) {
            self.verticalSpacingBetweenElements = verticalSpacingBetweenElements
            self.textBlockWidthFraction = textBlockWidthFraction
            self.highlightingTarget = highlightingTarget
            self.badgeOffset = badgeOffset
            self.badgeSize = badgeSize
            self.imageOrLabel = imageOrLabel
            self.content = content
            self.textStyles = textStyles
            self.detail = detail
            self.badge = badge
            self.accessory = accessory
            super.init(enforcesMinimumHeight: enforcesMinimumHeight)
        }

        public override func apply(to view: Component.DetailedDescription.View) {
            super.apply(to: view)
            view.numberOfLabels = textStyles.count

            view.badgeCenterYOffset.constant = badgeOffset.y
            view.badgeCenterXOffset.constant = badgeOffset.x
            view.badgeView.width.constant = badgeSize.width
            view.badgeView.height.constant = badgeSize.height

            view.labelsContainer.spacing = verticalSpacingBetweenElements
            view.textBlockWidthFraction = textBlockWidthFraction
            view.enforcesMinimumHeight = enforcesMinimumHeight

            content.apply(to: view.contentStackView)
            imageOrLabel.apply(to: view.imageOrLabelView)
            badge.apply(to: view.badgeView)
            accessory.apply(to: view.accessoryView)

            switch highlightingTarget {
            case .container:
                view.highlightingGesture.stylingView = view
            case .content:
                view.highlightingGesture.stylingView = view.contentStackView
            }

            zip(view.labels, textStyles).forEach { label, style in
                style.apply(to: label)
            }
            detail.apply(to: view.detailLabel)

            view.detailLabel.numberOfLines = 1
        }
    }
}
