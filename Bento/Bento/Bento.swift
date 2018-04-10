import UIKit

precedencegroup ComposingPrecedence {
    associativity: left
    higherThan: NodeConcatenationPrecedence
}

precedencegroup NodeConcatenationPrecedence {
    associativity: left
    higherThan: SectionConcatenationPrecedence
}

precedencegroup SectionConcatenationPrecedence {
    associativity: left
    higherThan: AdditionPrecedence
}

infix operator |-+: SectionConcatenationPrecedence
infix operator |--+: NodeConcatenationPrecedence
infix operator |--*: NodeConcatenationPrecedence
infix operator |--?: NodeConcatenationPrecedence
infix operator <>: ComposingPrecedence

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
    public func render<SectionId, RowId>(_ bento: Bento<SectionId, RowId>) {
        let adapter: SectionedFormAdapter<SectionId, RowId> = getAdapter()
        adapter.update(sections: bento.sections)
    }
}
