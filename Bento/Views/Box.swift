import UIKit

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

/// Box holds an array of sections which should be displayed on the screen.
/// Box **doesn't** have a visual representation.
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

extension Box: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "🍱 *** Bento: Box start" + sections.map {
            "\n" + $0.debugDescription
        }.joined() + "\n🍱 *** Bento: Box end\n"
    }
}
