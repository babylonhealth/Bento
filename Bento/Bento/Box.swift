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

public struct Box<SectionID: Hashable, ItemID: Hashable> {
    public typealias Section = Bento.Section<SectionID, ItemID>

    public var sections: [Section]

    public init(sections: [Section]) {
        self.sections = sections
    }

    public static var empty: Box {
        return Box(sections: [])
    }

    public static func |-+ (lhs: Box, rhs: Section) -> Box {
        return Box(sections: lhs.sections + [rhs])
    }
}

extension UICollectionView {
    public func render<SectionID, ItemID>(_ box: Box<SectionID, ItemID>, completion: (() -> Void)? = nil) {
        let adapter: CollectionViewDataSource<SectionID, ItemID> = getAdapter()
        adapter.update(sections: box.sections, completion: completion)
    }

    public func render<SectionID, ItemID>(_ box: Box<SectionID, ItemID>, animated: Bool) {
        let adapter: CollectionViewDataSource<SectionID, ItemID> = getAdapter()
        adapter.update(sections: box.sections, animated: animated)
    }
}
