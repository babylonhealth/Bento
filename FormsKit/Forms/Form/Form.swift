import UIKit

infix operator |-+: AdditionPrecedence
infix operator |--+: MultiplicationPrecedence
infix operator |--*: MultiplicationPrecedence
infix operator |--?: MultiplicationPrecedence

public struct Form<SectionId: Hashable, RowId: Hashable> {
    public let sections: [Section<SectionId, RowId>]

    public static var empty: Form {
        return Form(sections: [])
    }
}

public struct Section<SectionId: Hashable, RowId: Hashable> {
    fileprivate let header: SectionNode<SectionId>
    fileprivate let footer: SectionNode<SectionId>
    fileprivate let rows: [Node<RowId>]

    public init(header: SectionNode<SectionId> = .empty,
                footer: SectionNode<SectionId> = .empty,
                rows: [Node<RowId>] = []) {
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

    func renderTableHeader(in tableView: UITableView, for section: Int) -> UIView? {
        return header.render(in: tableView, for: section)
    }

    func renderTableFooter(in tableView: UITableView, for section: Int) -> UIView? {
        return footer.render(in: tableView, for: section)
    }

    func renderTableCell(in tableView: UITableView, for indexPath: IndexPath) -> UITableViewCell {
        return rows[indexPath.row].component.renderCell(in: tableView, for: indexPath)
    }
}

public func |-+<SectionId, RowId>(lhs: Form<SectionId, RowId>, rhs: Section<SectionId, RowId>) -> Form<SectionId, RowId> {
    return Form(sections: lhs.sections + [rhs])
}

public func |--+<SectionId, RowId>(lhs: Section<SectionId, RowId>, rhs: Node<RowId>) -> Section<SectionId, RowId> {
    return Section(id: lhs.id, header: lhs.header, footer: lhs.footer, rows: lhs.rows + [rhs])
}

public func |--*<SectionId, RowId>(lhs: Section<SectionId, RowId>, rhs: [Node<RowId>]) -> Section<SectionId, RowId> {
    return Section(id: lhs.id, header: lhs.header, footer: lhs.footer, rows: lhs.rows + rhs)
}

public func |--+<Identifier>(lhs: Node<Identifier>, rhs: Node<Identifier>) -> [Node<Identifier>] {
    return [lhs, rhs]
}

public func |--+<Identifier>(lhs: [Node<Identifier>], rhs: Node<Identifier>) -> [Node<Identifier>] {
    return lhs + [rhs]
}

