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
infix operator |---+: NodeConcatenationPrecedence
infix operator |---*: NodeConcatenationPrecedence
infix operator |---?: NodeConcatenationPrecedence
infix operator <>: ComposingPrecedence

public struct Box<SectionId: Hashable, RowId: Hashable> {
    public let sections: [Section<SectionId, RowId>]

    public init(sections: [Section<SectionId, RowId>]) {
        self.sections = sections
    }

    public static var empty: Box {
        return Box(sections: [])
    }
}

public func |-+<SectionId, RowId>(lhs: Box<SectionId, RowId>, rhs: Section<SectionId, RowId>) -> Box<SectionId, RowId> {
    return Box(sections: lhs.sections + [rhs])
}

extension UITableView {
    public func render<SectionId, RowId>(_ box: Box<SectionId, RowId>) {
        let adapter: SectionedFormAdapter<SectionId, RowId> = getAdapter()
        adapter.update(sections: box.sections, with: TableViewAnimation())
    }

    public func render<SectionId, RowId>(_ box: Box<SectionId, RowId>, animated: Bool) {
        let adapter: SectionedFormAdapter<SectionId, RowId> = getAdapter()
        if animated {
            adapter.update(sections: box.sections, with: TableViewAnimation())
        } else {
            adapter.update(sections: box.sections)
        }
    }

    public func render<SectionId, RowId>(_ box: Box<SectionId, RowId>, with animation: TableViewAnimation) {
        let adapter: SectionedFormAdapter<SectionId, RowId> = getAdapter()

        adapter.update(sections: box.sections, with: animation)
    }
}
