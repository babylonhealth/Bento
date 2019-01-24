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

public extension UICollectionView {
    func render<SectionID, ItemID>(_ box: Box<SectionID, ItemID>, completion: (() -> Void)? = nil) {
        let adapter: CollectionViewAdapterBase<SectionID, ItemID> = getAdapter()
        adapter.update(sections: box.sections, animated: false, completion: completion)
        didRenderBox()
    }

    func render<SectionID, ItemID>(_ box: Box<SectionID, ItemID>, animated: Bool) {
        let adapter: CollectionViewAdapterBase<SectionID, ItemID> = getAdapter()
        adapter.update(sections: box.sections, animated: animated, completion: nil)
        didRenderBox()
    }

    func render<SectionID, ItemID>(_ box: Box<SectionID, ItemID>, with layout: UICollectionViewLayout) {
        let adapter: CollectionViewAdapterBase<SectionID, ItemID> = getAdapter()
        adapter.update(sections: box.sections, layout: layout)
        didRenderBox()
    }
}
