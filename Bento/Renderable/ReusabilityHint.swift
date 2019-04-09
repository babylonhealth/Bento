public struct ReusabilityHint {
    internal enum Mark: Equatable {
        case node(Any.Type)
        case begin
        case end

        static func == (lhs: Mark, rhs: Mark) -> Bool {
            switch (lhs, rhs) {
            case let (.node(lhs), .node(rhs)):
                return lhs == rhs
            case (.begin, .begin), (.end, end):
                return true
            default:
                return false
            }
        }
    }

    internal var marks: [Mark]

    internal init<R: Renderable>(root: R) {
        marks = [.node(root.componentType), .begin]
    }

    public mutating func combine<R: Renderable>(_ component: R) {
        marks.append(.node(component.componentType))
        marks.append(.begin)
        component.makeReusabilityHint(&self)
        marks.append(.end)
    }

    func generate() -> String {
        // NOTE: It isn't quite important that we generate a very clean symbol. It only needs to be consistently
        //       reproduced.
        var symbol = marks.reduce(into: "") { buffer, mark in
            switch mark {
            case let .node(type):
                buffer += fullyQualifiedTypeName(of: type)
            case .begin:
                buffer += "["
            case .end:
                buffer += "]"
            }
        }

        // NOTE: Since the root node opens with a `begin` mark, we should balance it with an `end` mark.
        symbol += "]"
        return symbol
    }

    func isCompatible(with other: ReusabilityHint) -> Bool {
        return marks == other.marks
    }
}

func fullyQualifiedTypeName(of type: Any.Type) -> String {
    /// NOTE: `String.init(reflecting:)` gives the fully qualified type name.
    //        Tests would catch unexpeced type name printing behavior due to Swift runtime changes.
    return String(reflecting: type)
}
