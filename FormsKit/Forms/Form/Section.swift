import UIKit

public struct Section<SectionId: Hashable, RowId: Hashable> {
    let id: SectionId
    fileprivate let header: HeaderFooterNode?
    fileprivate let footer: HeaderFooterNode?
    fileprivate let rows: [Node<RowId>]

    public init<Header: Renderable, Footer: Renderable>(id: SectionId,
                                                        header: Header,
                                                        footer: Footer,
                                                        rows: [Node<RowId>] = []) {
        self.id = id
        self.header = HeaderFooterNode(component: header)
        self.footer = HeaderFooterNode(component: footer)
        self.rows = rows
    }
    
    public init<Header: Renderable>(id: SectionId,
                                    header: Header,
                                    rows: [Node<RowId>] = []) {
        self.id = id
        self.header = HeaderFooterNode(component: header)
        self.footer = nil
        self.rows = rows
    }
    
    public init<Footer: Renderable>(id: SectionId,
                                    footer: Footer,
                                    rows: [Node<RowId>] = []) {
        self.id = id
        self.header = nil
        self.footer = HeaderFooterNode(component: footer)
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
         header: HeaderFooterNode?,
         footer: HeaderFooterNode?,
         rows: [Node<RowId>]) {
        self.id = id
        self.header = header
        self.footer = footer
        self.rows = rows
    }

    func isEqualTo(_ other: Section) -> Bool {
        let areHeadersEqual = header.zip(with: other.header, ==) ?? false
        let areFootersEqual = footer.zip(with: other.footer, ==) ?? false
        return areHeadersEqual && areFootersEqual
    }

    var rowsCount: Int {
        return rows.count
    }

    func updateNode(in tableView: UITableView, at indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? TableViewCell,
            let containedView = cell.containedView else {
                assertionFailure()
                return
        }
        rows[indexPath.row].update(view: containedView)
    }

    func updateHeader(view: UIView) {
        guard let headerView = view as? TableViewHeaderFooterView,
            let contentView = headerView.containedView else { return }
        header?.update(view: contentView)
    }

    func updateFooter(view: UIView) {
        guard let headerView = view as? TableViewHeaderFooterView,
            let contentView = headerView.containedView else { return }
        footer?.update(view: contentView)
    }

    func renderHeader(in tableView: UITableView) -> UIView? {
        return header?.render(in: tableView)
    }

    func renderFooter(in tableView: UITableView) -> UIView? {
        return footer?.render(in: tableView)
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

extension Section: CustomStringConvertible {
    public var description: String {
        return "Section: \(id) rows: \(rows)\n"
    }
}

public func |--+<SectionId, RowId>(lhs: Section<SectionId, RowId>, rhs: Node<RowId>) -> Section<SectionId, RowId> {
    return Section(id: lhs.id, header: lhs.header, footer: lhs.footer, rows: lhs.rows + [rhs])
}

public func |--*<SectionId, RowId>(lhs: Section<SectionId, RowId>, rhs: [Node<RowId>]) -> Section<SectionId, RowId> {
    return Section(id: lhs.id, header: lhs.header, footer: lhs.footer, rows: lhs.rows + rhs)
}
