import UIKit

public struct Section<SectionId: Hashable, RowId: Hashable> {
    let id: SectionId
    let header: HeaderFooterNode?
    let footer: HeaderFooterNode?
    let rows: [Node<RowId>]

    public init<Header: Renderable, Footer: Renderable>(id: SectionId,
                                                        header: Header? = nil,
                                                        footer: Footer? = nil,
                                                        rows: [Node<RowId>] = []) {
        self.id = id
        self.header = header.map(HeaderFooterNode.init)
        self.footer = footer.map(HeaderFooterNode.init)
        self.rows = rows
    }

    init(id: SectionId,
         header: HeaderFooterNode?,
         footer: HeaderFooterNode?,
         rows: [Node<RowId>]) {
        self.id = id
        self.header = header
        self.footer = footer
        self.rows = rows
    }

    func equals(_ other: Section) -> Bool {
        let areHeadersEqual = header.zip(with: other.header, ==) ?? false
        let areFootersEqual = footer.zip(with: other.footer, ==) ?? false
        return areHeadersEqual && areFootersEqual
    }
}

extension Section: Collection {
    public var startIndex: Int {
        return rows.startIndex
    }

    public var endIndex: Int {
        return rows.endIndex
    }

    public func index(after i: Int) -> Int {
        return rows.index(after: i)
    }

    public subscript(position: Int) -> Node<RowId> {
        return rows[position]
    }
}

public func |--+<SectionId, RowId>(lhs: Section<SectionId, RowId>, rhs: Node<RowId>) -> Section<SectionId, RowId> {
    return Section(id: lhs.id, header: lhs.header, footer: lhs.footer, rows: lhs.rows + [rhs])
}

public func |--*<SectionId, RowId>(lhs: Section<SectionId, RowId>, rhs: [Node<RowId>]) -> Section<SectionId, RowId> {
    return Section(id: lhs.id, header: lhs.header, footer: lhs.footer, rows: lhs.rows + rhs)
}
