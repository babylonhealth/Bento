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
    let id: SectionId
    fileprivate let header: SectionNode
    fileprivate let footer: SectionNode
    fileprivate let rows: [Node<RowId>]

    public init(id: SectionId,
                header: SectionNode = .empty,
                footer: SectionNode = .empty,
                rows: [Node<RowId>] = []) {
        self.id = id
        self.header = header
        self.footer = footer
        self.rows = rows
    }

    var rowsCount: Int {
        return rows.count
    }
    
    func render(view: UIView, at index: Int) {
        rows[index].component.render(in: view)
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
        return "Section" + rows.reduce("") { (acum, node) in
            return " " + acum + "\(node.id)"
        }
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

