extension Optional {
    public static func iff(_ condition: @autoclosure () -> Bool, _ generator: @autoclosure () -> Wrapped) -> Wrapped? {
        if condition() {
            return generator()
        } else {
            return .none
        }
    }

    public static func iff(_ condition: @autoclosure () -> Bool, _ generator: () -> Wrapped) -> Wrapped? {
        if condition() {
            return generator()
        } else {
            return .none
        }
    }

    public static func iff(_ condition: () -> Bool, _ generator: () -> Wrapped) -> Wrapped? {
        if condition() {
            return generator()
        } else {
            return .none
        }
    }
}

extension Section {
    public static func |---? (lhs: Section, rhs: Item?) -> Section {
        if let item = rhs {
            return lhs |---+ item
        } else {
            return lhs
        }
    }

    public static func |---? (lhs: Section, rhs: [Item]?) -> Section {
        if let items = rhs {
            return lhs |---* items
        } else {
            return lhs
        }
    }
}

extension Box {
    public static func |-? (lhs: Box, rhs: Section?) -> Box {
        if let section = rhs {
            return lhs |-+ section
        } else {
            return lhs
        }
    }
}

public func |---?<Identifier>(lhs: Node<Identifier>, rhs: Node<Identifier>?) -> [Node<Identifier>] {
    if let node = rhs {
        return [lhs, node]
    } else {
        return [lhs]
    }
}

public func |---?<Identifier>(lhs: [Node<Identifier>], rhs: Node<Identifier>?) -> [Node<Identifier>] {
    if let node = rhs {
        return lhs + [node]
    } else {
        return lhs
    }
}
