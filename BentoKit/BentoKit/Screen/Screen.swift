import Bento

public struct Screen<SectionId: Hashable, RowId: Hashable> {
    public let leftBarItems: [BarButtonItem]
    public let rightBarItems: [BarButtonItem]
    public let titleItem: NavigationTitleItem
    public let formStyle: BentoTableView.Layout
    public let focusMode: FocusMode
    /// If not nil will override renderer configuration property
    public let shouldUseSystemSeparators: Bool?
    public let box: Box<SectionId, RowId>
    public let pinnedToTopBox: Box<SectionId, RowId>
    public let pinnedToBottomBox: Box<SectionId, RowId>

    public init(
        title: String,
        leftBarItems: [BarButtonItem] = [],
        rightBarItems: [BarButtonItem] = [],
        formStyle: BentoTableView.Layout = .topYAligned,
        focusMode: FocusMode = .never,
        shouldUseSystemSeparators: Bool? = nil,
        box: Box<SectionId, RowId>,
        pinnedToTopBox: Box<SectionId, RowId> = .empty,
        pinnedToBottomBox: Box<SectionId, RowId> = .empty
    ) {
        self.init(
            titleItem: .text(title),
            leftBarItems: leftBarItems,
            rightBarItems: rightBarItems,
            formStyle: formStyle,
            focusMode: focusMode,
            shouldUseSystemSeparators: shouldUseSystemSeparators,
            box: box,
            pinnedToTopBox: pinnedToTopBox,
            pinnedToBottomBox: pinnedToBottomBox
        )
    }

    public init(
        titleItem: NavigationTitleItem,
        leftBarItems: [BarButtonItem] = [],
        rightBarItems: [BarButtonItem] = [],
        formStyle: BentoTableView.Layout = .topYAligned,
        focusMode: FocusMode = .never,
        shouldUseSystemSeparators: Bool? = nil,
        box: Box<SectionId, RowId>,
        pinnedToTopBox: Box<SectionId, RowId> = .empty,
        pinnedToBottomBox: Box<SectionId, RowId> = .empty
    ) {
        self.leftBarItems = leftBarItems
        self.rightBarItems = rightBarItems
        self.titleItem = titleItem
        self.formStyle = formStyle
        self.focusMode = focusMode
        self.shouldUseSystemSeparators = shouldUseSystemSeparators
        self.box = box
        self.pinnedToTopBox = pinnedToTopBox
        self.pinnedToBottomBox = pinnedToBottomBox
    }
}

public enum FocusMode {
    /// Never focus automatically.
    case never

    /// Focus only once. It can be reset by changing back to `never`.
    case once
}

public struct BarButtonItem {
    public enum Appearance: Equatable {
        case text(String)
        case image(UIImage)
        case activityIndicator
    }

    let appearance: Appearance
    let isEnabled: Bool
    let callback: (() -> Void)?
    let accessibilityIdentifier: String?

    public init(appearance: Appearance,
                isEnabled: Bool = true,
                accessibilityIdentifier: String? = nil,
                callback: (() -> Void)? = nil) {
        self.appearance = appearance
        self.isEnabled = isEnabled
        self.callback = callback
        self.accessibilityIdentifier = accessibilityIdentifier
    }

    public func make(willTriggerAction: @escaping () -> Void) -> UIBarButtonItem {
        let item: UIBarButtonItem

        func action() {
            willTriggerAction()
            callback?()
        }

        switch appearance {
        case let .text(title):
            item = UIBarButtonItem(title: title, style: .plain, action: action)
        case let .image(image):
            item = UIBarButtonItem(image: image, style: .plain, action: action)
        case .activityIndicator:
            let view = UIActivityIndicatorView(style: .gray)
            view.startAnimating()
            item = UIBarButtonItem(customView: view)
        }

        return item.with {
            $0.isEnabled = isEnabled
            $0.accessibilityIdentifier = accessibilityIdentifier
        }
    }

    public func make() -> UIBarButtonItem {
        let item: UIBarButtonItem

        switch appearance {
        case let .text(title):
            item = UIBarButtonItem(title: title, style: .plain, action: { self.callback?() })
        case let .image(image):
            item = UIBarButtonItem(image: image, style: .plain, action: { self.callback?() })
        case .activityIndicator:
            let view = UIActivityIndicatorView(style: .gray)
            view.startAnimating()
            item = UIBarButtonItem(customView: view)
        }

        applyNonAppearanceChanges(to: item)
        return item
    }

    public func applyNonAppearanceChanges(to item: UIBarButtonItem, willTriggerAction: (() -> Void)? = nil) {
        item.didTap = {
            willTriggerAction?()
            self.callback?()
        }
        item.isEnabled = isEnabled
        item.accessibilityIdentifier = accessibilityIdentifier
    }

    public static func hasAppearanceChanged(_ lhs: BarButtonItem, _ rhs: BarButtonItem) -> Bool {
        return lhs.appearance == rhs.appearance
    }
}

public enum NavigationTitleItem {
    case text(String)
    case view(UIView)
}
