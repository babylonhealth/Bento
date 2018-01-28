public struct Section<SectionId: Hashable, RowId: Hashable> {
    let id: SectionId?
    fileprivate let header: HeaderFooterNode
    fileprivate let footer: HeaderFooterNode
    fileprivate let rows: [Node<RowId>]

    public init(id: SectionId? = nil,
                header: HeaderFooterNode = .empty,
                footer: HeaderFooterNode = .empty,
                rows: [Node<RowId>] = []) {
        self.id = id
        self.header = header
        self.footer = footer
        self.rows = rows
    }

    public static var empty: Section {
        return Section(header: .empty, footer: .empty, rows: [])
    }

    var rowsCount: Int {
        return rows.count
    }

    func renderHeader(in tableView: UITableView) -> UIView? {
        return header.render(in: tableView)
    }

    func renderFooter(in tableView: UITableView) -> UIView? {
        return footer.render(in: tableView)
    }

    func renderCell(in tableView: UITableView, at index: Int) -> UITableViewCell {
        return rows[index].renderCell(in: tableView)
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
