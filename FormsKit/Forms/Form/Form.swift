import UIKit

infix operator |-+: AdditionPrecedence
infix operator |--+: MultiplicationPrecedence
infix operator |--*: MultiplicationPrecedence
infix operator |--?: MultiplicationPrecedence

public struct Form<SectionId: Hashable, RowId: Hashable> {
    fileprivate let sections: [Section<SectionId, RowId>]

    public static var empty: Form {
        return Form(sections: [])
    }

    public func render(in tableView: UITableView) {
        let adapter: SectionedFormAdapter<SectionId, RowId> = tableView.getAdapter()
        adapter.update(sections: sections)
    }
}

public func |-+<SectionId, RowId>(lhs: Form<SectionId, RowId>, rhs: Section<SectionId, RowId>) -> Form<SectionId, RowId> {
    return Form(sections: lhs.sections + [rhs])
}
