public struct ReusabilityHintCombiner {
    internal var types: [Any.Type]

    internal init<R: Renderable>(root: R) {
        types = [root.componentType]
    }

    public mutating func combine<R: Renderable>(_ component: R) {
        types.append(component.componentType)
        component.makeReusabilityHint(using: &self)
    }

    __consuming func generate() -> String {
        return types.map(fullyQualifiedTypeName(of:)).joined(separator: ",")
    }

    __consuming func isCompatible(with other: __owned ReusabilityHintCombiner) -> Bool {
        return types.elementsEqual(other.types, by: ==)
    }
}


func fullyQualifiedTypeName(of type: Any.Type) -> String {
    /// NOTE: `String.init(reflecting:)` gives the fully qualified type name.
    //        Tests would catch unexpeced type name printing behavior due to Swift runtime changes.
    return String(reflecting: type)
}
