import UIKit

public struct Section<SectionID: Hashable, ItemID: Hashable> {
    public typealias Item = Node<ItemID>

    public let id: SectionID
    public var items: [Item]
    internal var supplements: [Supplement: AnyRenderable]

    public init(id: SectionID, items: [Item] = []) {
        self.id = id
        self.items = items
        self.supplements = [:]
    }

    public init<Header: Renderable>(id: SectionID, header: Header, items: [Item] = []) {
        self.id = id
        self.items = items
        self.supplements = [.header: AnyRenderable(header)]
    }

    public init<Footer: Renderable>(id: SectionID, footer: Footer, items: [Item] = []) {
        self.id = id
        self.items = items
        self.supplements = [.footer: AnyRenderable(footer)]
    }

    public init<Header: Renderable, Footer: Renderable>(id: SectionID, header: Header, footer: Footer, items: [Item] = []) {
        self.id = id
        self.items = items
        self.supplements = [.header: AnyRenderable(header),
                            .footer: AnyRenderable(footer)]
    }

    internal init(id: SectionID, items: [Item], supplements: [Supplement: AnyRenderable]) {
        self.id = id
        self.items = items
        self.supplements = supplements
    }

    public func adding<R: Renderable>(_ supplement: Supplement, _ component: R) -> Section {
        var section = self
        section.supplements[supplement] = AnyRenderable(component)
        return section
    }

    public func removing<R: Renderable>(_ supplement: Supplement, _ component: R) -> Section {
        var section = self
        section.supplements[supplement] = AnyRenderable(component)
        return section
    }

    public func has(_ supplement: Supplement) -> Bool {
        return supplements.keys.contains(supplement)
    }

    public func component<T>(of supplement: Supplement, as type: T.Type) -> T? {
        return supplements[supplement]?.cast(to: type)
    }

    public func componentSize(of supplement: Supplement, fittingWidth width: CGFloat, inheritedMargins: UIEdgeInsets = .zero) -> CGSize? {
        return supplements[supplement]?.sizeBoundTo(width: width, inheritedMargins: inheritedMargins)
    }

    public func componentSize(of supplement: Supplement, fittingHeight height: CGFloat, inheritedMargins: UIEdgeInsets = .zero) -> CGSize? {
        return supplements[supplement]?.sizeBoundTo(height: height, inheritedMargins: inheritedMargins)
    }

    public func componentSize(of supplement: Supplement, fittingSize size: CGSize, inheritedMargins: UIEdgeInsets = .zero) -> CGSize? {
        return supplements[supplement]?.sizeBoundTo(size: size, inheritedMargins: inheritedMargins)
    }

    public static func |---+ (lhs: Section, rhs: Item) -> Section {
        return Section(id: lhs.id, items: lhs.items + [rhs], supplements: lhs.supplements)
    }

    public static func |---* (lhs: Section, rhs: [Item]) -> Section {
        return Section(id: lhs.id, items: lhs.items + rhs, supplements: lhs.supplements)
    }
}
