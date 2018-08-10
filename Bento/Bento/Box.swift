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
infix operator |-?: SectionConcatenationPrecedence
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

extension UICollectionView {
    public func render<SectionId, ItemId>(_ box: Box<SectionId, ItemId>, completion: (() -> Void)? = nil) {
        let adapter: CollectionViewDataSource<SectionId, ItemId> = getAdapter()
        adapter.update(sections: box.sections, completion: completion)
    }

    public func render<SectionId, ItemId>(_ box: Box<SectionId, ItemId>, animated: Bool) {
        let adapter: CollectionViewDataSource<SectionId, ItemId> = getAdapter()
        adapter.update(sections: box.sections, animated: animated)
    }
}
