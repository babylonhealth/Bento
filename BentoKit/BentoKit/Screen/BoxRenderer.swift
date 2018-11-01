import Bento
import StyleSheets
import Foundation

public typealias EmptyConfig = Void

public protocol BoxRenderer {
    typealias Sink<Action> = (Action) -> Void
    associatedtype State
    associatedtype Action
    associatedtype Appearance: BoxAppearance
    associatedtype Config = EmptyConfig
    associatedtype SectionID: Hashable
    associatedtype ItemID: Hashable

    var styleSheet: ViewStyleSheet<UIView> { get }
    var pinnedToTopBoxStyleSheet: ViewStyleSheet<UIView> { get }
    var pinnedToBottomBoxStyleSheet: ViewStyleSheet<UIView> { get }
    var configuration: BoxConfiguration { get }

    init(observer: @escaping Sink<Action>, appearance: Appearance, config: Config)

    func render(state: State) -> Screen<SectionID, ItemID>
}

extension BoxRenderer where Config == EmptyConfig {
    public init(observer: @escaping Sink<Action>, appearance: Appearance) {
        self.init(observer: observer, appearance: appearance, config: ())
    }
}

extension BoxRenderer {
    public var styleSheet: ViewStyleSheet<UIView> {
        return ViewStyleSheet(backgroundColor: .white)
    }

    public var pinnedToTopBoxStyleSheet: ViewStyleSheet<UIView> {
        return ViewStyleSheet(backgroundColor: .clear)
    }

    public var pinnedToBottomBoxStyleSheet: ViewStyleSheet<UIView> {
        return ViewStyleSheet(backgroundColor: .clear)
    }

    public var configuration: BoxConfiguration {
        return BoxConfiguration()
    }

    public func renderSpace<ItemID>(height: CGFloat,
                                   styleSheet: ViewStyleSheet<UIView> = .init(),
                                   rowId: @autoclosure () -> ItemID) -> Node<ItemID> {
        return Node(
            id: rowId(),
            component: Component.EmptySpace(height: height, styleSheet: styleSheet)
        )
    }
}

public struct BoxConfiguration {
    public let shouldUseSystemSeparators: Bool

    public init(
        shouldUseSystemSeparators: Bool = true
    ) {
        self.shouldUseSystemSeparators = shouldUseSystemSeparators
    }
}

public func |-+ <SectionID, ItemID>(lhs: Box<SectionID, ItemID>, rhs: [Section<SectionID, ItemID>]) -> Box<SectionID, ItemID> {
    return Box(sections: lhs.sections + rhs)
}
