import UIKit

infix operator |-+: AdditionPrecedence
infix operator |--+: MultiplicationPrecedence
infix operator |--*: MultiplicationPrecedence
infix operator |--?: MultiplicationPrecedence
infix operator <>: BitwiseShiftPrecedence

public struct Bento<SectionId: Hashable, RowId: Hashable> {
    public let sections: [Section<SectionId, RowId>]

    public init(sections: [Section<SectionId, RowId>]) {
        self.sections = sections
    }

    public static var empty: Bento {
        return Bento(sections: [])
    }
}

public func |-+<SectionId, RowId>(lhs: Bento<SectionId, RowId>, rhs: Section<SectionId, RowId>) -> Bento<SectionId, RowId> {
    return Bento(sections: lhs.sections + [rhs])
}

extension UITableView {
    public func render<SectionId, RowId>(form: Bento<SectionId, RowId>) {
        let adapter: SectionedFormAdapter<SectionId, RowId> = getAdapter()
        let animation = TableViewAnimation(sectionInsertion: .fade,
                                           sectionDeletion: .fade,
                                           rowDeletion: .fade,
                                           rowInsertion: .fade)
        adapter.update(sections: form.sections, with: animation)
    }

    public func render<SectionId, RowId>(form: Bento<SectionId, RowId>, animated: Bool = true) {
        let adapter: SectionedFormAdapter<SectionId, RowId> = getAdapter()
        if animated {
            let animation = TableViewAnimation(sectionInsertion: .fade,
                                               sectionDeletion: .fade,
                                               rowDeletion: .fade,
                                               rowInsertion: .fade)
            adapter.update(sections: form.sections, with: animation)
        } else {
            adapter.update(sections: form.sections)
        }
    }

    public func render<SectionId, RowId>(form: Bento<SectionId, RowId>, with animation: TableViewAnimation) {
        let adapter: SectionedFormAdapter<SectionId, RowId> = getAdapter()

        adapter.update(sections: form.sections, with: animation)
    }
}
