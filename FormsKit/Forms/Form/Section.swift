import UIKit

public struct Section<SectionId: Hashable, RowId: Hashable> {
    let id: SectionId
    let header: AnyRenderable?
    let footer: AnyRenderable?
    let rows: [Node<RowId>]

    public init<Header: Renderable, Footer: Renderable>(id: SectionId,
                                                        header: Header,
                                                        footer: Footer,
                                                        rows: [Node<RowId>] = [])
        where Header.View: UIView, Footer.View: UIView {
        self.id = id
        self.header = AnyRenderable(header)
        self.footer = AnyRenderable(footer)
        self.rows = rows
    }

    public init<Header: Renderable>(id: SectionId,
                                    header: Header,
                                    rows: [Node<RowId>] = []) where Header.View: UIView {
        self.id = id
        self.header = AnyRenderable(header)
        self.footer = nil
        self.rows = rows
    }

    public init<Footer: Renderable>(id: SectionId,
                                    footer: Footer,
                                    rows: [Node<RowId>] = []) where Footer.View: UIView {
        self.id = id
        self.header = nil
        self.footer = AnyRenderable(footer)
        self.rows = rows
    }

    public init(id: SectionId,
                rows: [Node<RowId>] = []) {
        self.id = id
        self.header = nil
        self.footer = nil
        self.rows = rows
    }

    init(id: SectionId,
         header: AnyRenderable?,
         footer: AnyRenderable?,
         rows: [Node<RowId>]) {
        self.id = id
        self.header = header
        self.footer = footer
        self.rows = rows
    }

    func equals(to other: Section) -> Bool {
        let areHeadersEqual = header.zip(with: other.header, ==)
        let areFootersEqual = footer.zip(with: other.footer, ==)
        return (areHeadersEqual ?? false) && (areFootersEqual ?? false)
    }
}

public func |--+<SectionId, RowId>(lhs: Section<SectionId, RowId>, rhs: Node<RowId>) -> Section<SectionId, RowId> {
    return Section(id: lhs.id, header: lhs.header, footer: lhs.footer, rows: lhs.rows + [rhs])
}

public func |--*<SectionId, RowId>(lhs: Section<SectionId, RowId>, rhs: [Node<RowId>]) -> Section<SectionId, RowId> {
    return Section(id: lhs.id, header: lhs.header, footer: lhs.footer, rows: lhs.rows + rhs)
}
