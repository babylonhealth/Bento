/// It adds possibility to add a Box/Section/Node into existing Box when given condition is met (equals true).
/// It's represented by `|-?` or `|---?` operators.
/// ```
///  Box.empty
///      |-? .iff(state.isSectionVisible) {
///          renderSection()
///      }
/// ```
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

/// Special case of `If` operator.
/// It allows to use Optional<T> and add a Box/Section/Node into existing Box only when the optional is not nil.
/// Oposite to `If` operator, `Some` unwrapps the optional and passes the unwrapped value to the closure.
/// It's also represented by `|-?` or `|---?` operators.
/// ```
///  Box.empty
///      |-? .some(state.someOptionalValue) { unwrappedValue in
///          render(unwrappedValue)
///      }
/// ```
public struct Some<T, U> {
    let optional: T?
    let generator: (T) -> U

    public static func some(_ optional: T?, _ generator: @escaping (T) -> U) -> Some<T, U> {
        return Some(optional: optional, generator: generator)
    }
}

extension Section {
    public static func |---? (lhs: Section, rhs: If<Item>) -> Section {
        if rhs.condition() {
            return lhs
                |---+ rhs.generator()
        }
        return lhs
    }

    public static func |---? (lhs: Section, rhs: If<[Item]>) -> Section {
        if rhs.condition() {
            return lhs
                |---* rhs.generator()
        }
        return lhs
    }

    public static func |---? <T>(lhs: Section, rhs: Some<T, Item>) -> Section {
        return rhs.optional.map { value in
            lhs |---+ rhs.generator(value)
        } ?? lhs
    }

    public static func |---? <T>(lhs: Section, rhs: Some<T, [Item]>) -> Section {
        return rhs.optional.map { value in
            lhs |---* rhs.generator(value)
        } ?? lhs
    }
}

extension Box {
    public static func |-? (lhs: Box, rhs: If<Section>) -> Box {
        if rhs.condition() {
            return lhs
                |-+ rhs.generator()
        }
        return lhs
    }

    public static func |-? <T>(lhs: Box, rhs: Some<T, Section>) -> Box {
        return rhs.optional.map { value in
            lhs |-+ rhs.generator(value)
        } ?? lhs
    }
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
