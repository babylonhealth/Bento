public struct If<T> {
    let condition: () -> Bool
    let generator: () -> T

    public static func iff(_ condition: @autoclosure @escaping () -> Bool, _ generator: @autoclosure @escaping () -> T) -> If<T> {
        return If(condition: condition, generator: generator)
    }

    public static func iff(_ condition: @autoclosure @escaping () -> Bool, _ generator: @escaping () -> T) -> If<T> {
        return If(condition: condition, generator: generator)
    }

    public static func iff(_ condition: @escaping () -> Bool, _ generator: @escaping () -> T) -> If<T> {
        return If(condition: condition, generator: generator)
    }
}

public struct Some<T, U> {
    let optional: T?
    let generator: (T) -> U

    public static func some(_ optional: T?, _ generator: @escaping (T) -> U) -> Some<T, U> {
        return Some(optional: optional, generator: generator)
    }
}

public func |---?<SectionId, RowId>(lhs: Section<SectionId, RowId>, rhs: If<Node<RowId>>) -> Section<SectionId, RowId> {
    if rhs.condition() {
        return lhs
            |---+ rhs.generator()
    }
    return lhs
}

public func |---?<SectionId, RowId>(lhs: Section<SectionId, RowId>, rhs: If<[Node<RowId>]>) -> Section<SectionId, RowId> {
    if rhs.condition() {
        return lhs
            |---* rhs.generator()
    }
    return lhs
}

public func |---?<T, SectionId, RowId>(lhs: Section<SectionId, RowId>, rhs: Some<T, Node<RowId>>) -> Section<SectionId, RowId> {
    return rhs.optional.map { value in
        lhs |---+ rhs.generator(value)
    } ?? lhs
}

public func |---?<T, SectionId, RowId>(lhs: Section<SectionId, RowId>, rhs: Some<T, [Node<RowId>]>) -> Section<SectionId, RowId> {
    return rhs.optional.map { value in
        lhs |---* rhs.generator(value)
    } ?? lhs
}

public func |-?<SectionId, RowId>(lhs: Box<SectionId, RowId>, rhs: If<Section<SectionId, RowId>>) -> Box<SectionId, RowId> {
    if rhs.condition() {
        return lhs
            |-+ rhs.generator()
    }
    return lhs
}

public func |-?<T, SectionId, RowId>(lhs: Box<SectionId, RowId>, rhs: Some<T, Section<SectionId, RowId>>) -> Box<SectionId, RowId> {
    return rhs.optional.map { value in
        lhs |-+ rhs.generator(value)
    } ?? lhs
}

public func |---?<Identifier>(lhs: Node<Identifier>, rhs: If<Node<Identifier>>) -> [Node<Identifier>] {
    if rhs.condition() {
        return [lhs, rhs.generator()]
    }

    return [lhs]
}

public func |---?<Identifier>(lhs: [Node<Identifier>], rhs: If<Node<Identifier>>) -> [Node<Identifier>] {
    if rhs.condition() {
        return lhs + [rhs.generator()]
    }

    return lhs
}

public func |---?<T, Identifier>(lhs: Node<Identifier>, rhs: Some<T, Node<Identifier>>) -> [Node<Identifier>] {
    return rhs.optional.map { value in
        [lhs, rhs.generator(value)]
        } ?? [lhs]
}

public func |---?<T, Identifier>(lhs: [Node<Identifier>], rhs: Some<T, Node<Identifier>>) -> [Node<Identifier>] {
    return rhs.optional.map { value in
        lhs + [rhs.generator(value)]
        } ?? lhs
}
