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

public func |-+<SectionId, RowId>(lhs: Form<SectionId, RowId>, rhs: Section<SectionId, RowId>) -> Form<SectionId, RowId> {
    return Form(sections: lhs.sections + [rhs])
}

extension UITableView {
    public func render<SectionId, RowId>(form: Form<SectionId, RowId>) {
        let adapter: SectionedFormAdapter<SectionId, RowId> = getAdapter()
        adapter.update(sections: form.sections)
    }
}
