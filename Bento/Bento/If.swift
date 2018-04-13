public struct If<T> {
    let condition: () -> Bool
    let generator: () -> T

    public static func iff(_ condition: @autoclosure @escaping () -> Bool, _ generator: @autoclosure @escaping () -> T) -> If<T> {
        return If(condition: condition, generator: generator)
    }

    public static func iff(_ condition: @escaping () -> Bool, _ generator: @escaping () -> T) -> If<T> {
        return If(condition: condition, generator: generator)
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
