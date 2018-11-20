import Bento
import StyleSheets
import ReactiveSwift
import ReactiveCocoa

private let maxImageWidth: CGFloat = 100

public extension Component {
    /// `TitledDescription` supports a horizontal layout comprising:
    ///
    /// (1) [Optional] an image or a text placeholder, at most 100 points in width,
    ///     with an optional badge icon whose position is customisable;
    /// (2) [Optional] a vertical stack of zero or more independent text labels;
    /// (3) [Optional] a single-line detail label; and
    /// (4) [Optional] an accessory.
    ///
    /// While `TitledDescription` supports asynchronous loading for its image
    /// view, you are obligated to ensure a consistent fixed size across all
    /// changes.
    public final class TitledDescription: AutoRenderable, Deletable, HeightCustomizing, Focusable, ComponentLifecycleAware {
        public typealias Accessory = AccessoryView.Accessory

        private let _willDisplayItem: (() -> Void)?
        private let _didEndDisplayingItem: (() -> Void)?
        public let focusEligibility: FocusEligibility
        public let configurator: (View) -> Void
        public let deleteActionText: String
        public let styleSheet: StyleSheet

        public var canBeDeleted: Bool {
            return didDelete != nil
        }

        public func delete() {
            didDelete?()
        }

        public func estimatedHeight(forWidth width: CGFloat,
                                    inheritedMargins: UIEdgeInsets) -> CGFloat {
            return heightComputer(width, inheritedMargins)
        }

        public func height(forWidth width: CGFloat,
                           inheritedMargins: UIEdgeInsets) -> CGFloat {
            return heightComputer(width, inheritedMargins)
        }

        @available(*, deprecated, message: "Please use the designated initialiser.")
        public convenience init(
            title: String,
            attributedText: NSAttributedString? = nil,
            subtitle: String? = nil,
            detail: String? = nil,
            image: Property<BentoKit.ImageOrLabel>? = nil,
            accessory: Accessory = .chevron,
            badgeIcon: UIImage? = nil,
            isEnabled: Bool = true,
            inputNodes: CustomInput? = nil,
            didTap: Optional<() -> Void> = nil,
            didTapAccessory: Optional<() -> Void> = nil,
            deleteAction: DeleteAction = .none,
            willDisplayItem: (() -> Void)? = nil,
            didEndDisplayingItem: (() -> Void)? = nil,
            styleSheet: StyleSheet = .init()
        ) {
            let titleText: TextValue
            if let attributedText = attributedText {
                titleText = .rich(attributedText)
            } else {
                titleText = .plain(title)
            }

            let texts: [TextValue]
            if let subtitle = subtitle {
                texts = [titleText, .plain(subtitle)]
            } else {
                texts = [titleText]
            }

            let detailText: TextValue?
            if let detail = detail {
                detailText = TextValue.plain(detail)
            } else {
                detailText = nil
            }

            self.init(
                texts: texts,
                detail: detailText,
                image: image,
                accessory: accessory,
                badgeIcon: badgeIcon,
                isEnabled: isEnabled,
                inputNodes: inputNodes,
                didTap: didTap,
                didTapAccessory: didTapAccessory,
                deleteAction: deleteAction,
                willDisplayItem: willDisplayItem,
                didEndDisplayingItem: didEndDisplayingItem,
                styleSheet: styleSheet
            )
        }

        public init(
            texts: [TextValue] = [],
            detail: TextValue? = nil,
            image: Property<BentoKit.ImageOrLabel>? = nil,
            accessory: Accessory = .chevron,
            badgeIcon: UIImage? = nil,
            isEnabled: Bool = true,
            inputNodes: CustomInput? = nil,
            didTap: (() -> Void)? = nil,
            didTapAccessory: (() -> Void)? = nil,
            deleteAction: DeleteAction = .none,
            willDisplayItem: (() -> Void)? = nil,
            didEndDisplayingItem: (() -> Void)? = nil,
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

                view.disposable = image?.producer.startWithValues(view.imageOrLabelView.reactive.content.action)
                view.imageOrLabelView.isHidden = image == nil

                view.accessoryView.accessory = accessory
                view.accessoryView.didTap = didTapAccessory

                view.badgeView.imageView.image = badgeIcon
                view.badgeView.isHidden = badgeIcon == nil

                view.inputNodes = inputNodes
                view.highlightingGesture.didTap = inputNodes != nil
                    ? .manual
                    : didTap.map(HighlightingGesture.TapAction.resign)
                view.highlightingGesture.didRebindView()
            }

            self.heightComputer = TitledDescription.heightComputer(
                styleSheet: styleSheet,
                image: image,
                texts: texts,
                detail: detail,
                accessory: accessory
            )

            switch inputNodes {
            case .none:
                self.focusEligibility = .ineligible
            case .some:
                let isPopulated = detail.map { $0.isEmpty == false } ?? false
                self.focusEligibility = .eligible(isPopulated ? .populated : .empty)
            }
            self.styleSheet = styleSheet
            self.deleteActionText = deleteAction.title ?? ""
            self.didDelete = deleteAction.callback
            self._willDisplayItem = willDisplayItem
            self._didEndDisplayingItem = didEndDisplayingItem
        }

        private let heightComputer: (CGFloat, UIEdgeInsets) -> CGFloat
        private let didDelete: (() -> Void)?
        
        public func willDisplayItem() {
            _willDisplayItem?()
        }
        
        public func didEndDisplayingItem() {
            _didEndDisplayingItem?()
        }
    }
}

private extension Component.TitledDescription {

    static func heightComputer(
        styleSheet: StyleSheet,
        image: Property<ImageOrLabel>?,
        texts: [TextValue],
        detail: TextValue?,
        accessory: Accessory
    ) -> (CGFloat, UIEdgeInsets) -> CGFloat {
        return { width, inheritedMargins in
            guard width > 0 else { return 0 }

            let xSpacing = styleSheet.content.spacing
            let verticalMargins = styleSheet.layoutMargins.verticalTotal
                + (styleSheet.content.isLayoutMarginsRelativeArrangement
                    ? styleSheet.content.layoutMargins.verticalTotal
                    : 0)

            let detailWidth = detail?.width(using: styleSheet.detail) ?? 0
            let detailHeight = detail?.height(using: styleSheet.detail,
                                              fittingWidth: detailWidth) ?? 0

            let detailWidthPlusSpacing: CGFloat
            if detail != nil && detailWidth > 0 {
                detailWidthPlusSpacing = detailWidth + xSpacing
            } else {
                detailWidthPlusSpacing = 0
            }

            let availableWidthForLabelBlock = width
                - max(styleSheet.layoutMargins.left, inheritedMargins.left)
                - max(styleSheet.layoutMargins.right, inheritedMargins.right)
                - (styleSheet.content.isLayoutMarginsRelativeArrangement
                    ? styleSheet.content.layoutMargins.horizontalTotal
                    : 0)
                - imageWidthPlusSpacing(measuring: image, styleSheet: styleSheet)
                - detailWidthPlusSpacing
                - (accessory != .none ? 24 + xSpacing : 0)

            assert(availableWidthForLabelBlock > 0,
                   "availableWidthForLabelBlock (\(availableWidthForLabelBlock)) ≤ 0")

            let textHeights = texts
                .enumerated()
                .filter { $0.element.isNotEmpty }
                .map { entry -> CGFloat in
                    let (index, text) = entry
                    return text.height(using: styleSheet.textStyles[index],
                                       fittingWidth: availableWidthForLabelBlock)
            }

            let textHeightsPlusSpacing = textHeights.reduce(0, +) +
                CGFloat(max(0, textHeights.count - 1)) * styleSheet.verticalSpacingBetweenElements

            return max(
                verticalMargins + max(
                    textHeightsPlusSpacing,
                    styleSheet.imageOrLabel.fixedSize?.height ?? 0,
                    detailHeight
                ),
                styleSheet.enforcesMinimumHeight ? 44 : 0
            )
        }
    }

    static func imageWidthPlusSpacing(measuring image: Property<ImageOrLabel>?,
                                      styleSheet: StyleSheet) -> CGFloat {
        let width: CGFloat

        if let size = styleSheet.imageOrLabel.fixedSize {
            width = size.width
        } else {
            switch image?.value {
            case let .image(image)?:
                width = image.size.width
                    + styleSheet.imageOrLabel.layoutMargins.left
                    + styleSheet.imageOrLabel.layoutMargins.right
            case let .text(text)?:
                width = (text as NSString)
                    .size(withAttributes: [.font: styleSheet.imageOrLabel.label.font])
                    .width
                    .rounded(.up)
            case .none?:
                width = 0
            case nil:
                return 0
            }
        }

        return min(width, maxImageWidth) + styleSheet.content.spacing
    }
}

extension Component.TitledDescription {

    @objc(TitledDescriptionView)
    public final class View: InteractiveView {

        var numberOfLabels: Int = 2 {
            didSet {
                guard numberOfLabels != oldValue else { return }
                processChangeInLabelCount()
            }
        }

        var inputNodes: CustomInput? {
            didSet {
                guard isFirstResponder else { return }
                if let nodes = inputNodes {
                    customInputView?.update(nodes)
                    reloadInputViews()
                } else {
                    _ = resignFirstResponder()
                }
            }
        }

        override init(frame: CGRect) {
            self.labels = (0 ..< numberOfLabels).map { _ in UILabel() }
            self.labelsContainer = stack(.vertical,
                                         spacing: 8.0,
                                         distribution: .fill,
                                         alignment: .leading,
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
        fileprivate var customInputView: InputView?
        fileprivate var focusToolbar: FocusToolbar?

        fileprivate var disposable: Disposable? {
            willSet { disposable?.dispose() }
        }

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

extension Component.TitledDescription.View {

    public override var inputView: UIView? {
        return customInputView
    }

    public override var inputAccessoryView: UIView? {
        return focusToolbar
    }

    public override func becomeFirstResponder() -> Bool {
        if let nodes = inputNodes {
            customInputView = InputView()
            focusToolbar = FocusToolbar(view: self)
            customInputView!.update(nodes)
        }

        if super.becomeFirstResponder() {
            highlightingGesture.isHighlighted = true
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(keyboardDidDisappear),
                name: UIResponder.keyboardDidHideNotification,
                object: nil
            )
            return true
        }

        customInputView = nil
        focusToolbar = nil
        return false
    }

    public override func resignFirstResponder() -> Bool {
        highlightingGesture.isHighlighted = false
        return super.resignFirstResponder()
    }
}

extension Component.TitledDescription.View: FocusableView {

    public func focus() {
        _ = becomeFirstResponder()
    }

    private func neighboringFocusEligibilityDidChange() {
        focusToolbar?.updateFocusEligibility(with: self)
        reloadInputViews()
    }
}

fileprivate extension Component.TitledDescription.View {

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

private extension Component.TitledDescription.View {

    @objc func keyboardDidDisappear() {
        if isFirstResponder { _ = resignFirstResponder() }
        customInputView = nil
        focusToolbar = nil
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardDidHideNotification,
            object: nil
        )
    }

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

public extension Component.TitledDescription {
    public final class ContentStyleSheet: ViewStyleSheet<BaseStackView> {
        public var spacing: CGFloat
        public var distribution: UIStackView.Distribution
        public var alignment: UIStackView.Alignment
        public var isLayoutMarginsRelativeArrangement: Bool

        public init(
            spacing: CGFloat = 16,
            distribution: UIStackView.Distribution = .fill,
            alignment: UIStackView.Alignment = .center,
            isLayoutMarginsRelativeArrangement: Bool = false
            ) {
            self.spacing = spacing
            self.distribution = distribution
            self.alignment = alignment
            self.isLayoutMarginsRelativeArrangement = isLayoutMarginsRelativeArrangement
        }

        public override func apply(to element: BaseStackView) {
            super.apply(to: element)
            element.spacing = spacing
            element.distribution = distribution
            element.alignment = alignment
            element.isLayoutMarginsRelativeArrangement = isLayoutMarginsRelativeArrangement
            element.cornerRadius = cornerRadius
            element.borderColor = borderColor?.cgColor
            element.borderWidth = borderWidth
        }
    }

    public final class StyleSheet: BaseViewStyleSheet<View> {

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

        @available(*, deprecated, message: "Please use textBlockWidthFraction.")
        public var titleWidthFraction: CGFloat? {
            get { return textBlockWidthFraction }
            set { textBlockWidthFraction = newValue }
        }

        @available(*, deprecated, message: "Please use textStyles.")
        public var title: LabelStyleSheet {
            get { return textStyles[0] }
            set { textStyles[0] = newValue }
        }

        @available(*, deprecated, message: "Please use textStyles.")
        public var subtitle: LabelStyleSheet {
            get { return textStyles[1] }
            set { textStyles[1] = newValue }
        }
        @available(*, deprecated, message: "Please use the designated initialiser.")
        public convenience init(
            verticalSpacingBetweenElements: CGFloat = 8.0,
            titleWidthFraction: CGFloat? = nil,
            highlightingTarget: HighlightingTarget = HighlightingTarget.container,
            badgeOffset: CGPoint = .zero,
            badgeSize: CGSize = CGSize(width: 12, height: 12),
            enforcesMinimumHeight: Bool = true,
            content: ContentStyleSheet = .init(),
            imageOrLabel: ImageOrLabelView.StyleSheet = .init(),
            title: LabelStyleSheet = .init(),
            subtitle: LabelStyleSheet = .init(font: UIFont.preferredFont(forTextStyle: .footnote),
                                              textColor: .gray),
            detail: LabelStyleSheet = .init(textAlignment: .trailing),
            badge: ViewStyleSheet<UIView> = ViewStyleSheet<UIView>()
        ) {
            self.init(
                verticalSpacingBetweenElements: verticalSpacingBetweenElements,
                textBlockWidthFraction: titleWidthFraction,
                highlightingTarget: highlightingTarget,
                badgeOffset: badgeOffset,
                badgeSize: badgeSize,
                enforcesMinimumHeight: enforcesMinimumHeight,
                content: content,
                imageOrLabel: imageOrLabel,
                textStyles: [title, subtitle],
                detail: detail,
                badge: badge
            )
        }

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
            badge: ViewStyleSheet<UIView> = ViewStyleSheet<UIView>()
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
            super.init(enforcesMinimumHeight: enforcesMinimumHeight)
        }

        public override func apply(to view: Component.TitledDescription.View) {
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
