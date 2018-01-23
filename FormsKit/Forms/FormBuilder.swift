precedencegroup ChainingPrecedence {
    associativity: left
    higherThan: TernaryPrecedence
}

infix operator |-+ : ChainingPrecedence // Compose with a new component
infix operator |-* : ChainingPrecedence // Compose with another builder
infix operator |-? : ChainingPrecedence // Compose components pending on a boolean condition
infix operator |-| : ChainingPrecedence // Compose with an empty space using a specific height

public struct FormBuilder<Identifier: Hashable> {
    private let components: [FormItem<Identifier>]

    public static var empty: FormBuilder {
        return FormBuilder()
    }

    private init(_ components: [FormItem<Identifier>] = []) {
        self.components = components
    }

    public static func |-+(builder: FormBuilder, component: FormItem<Identifier>) -> FormBuilder {
        return FormBuilder(builder.components + [component])
    }

    public static func |-* (builder: FormBuilder, components: [FormItem<Identifier>]) -> FormBuilder {
        return FormBuilder(builder.components + components)
    }

    public static func |-* (builder: FormBuilder, other: FormBuilder) -> FormBuilder {
        return FormBuilder(builder.components + other.components)
    }

    public static func |-* (builder: FormBuilder, generator: () -> FormBuilder) -> FormBuilder {
        return FormBuilder(builder.components + generator().components)
    }

    public func build() -> [FormItem<Identifier>] {
        return components
    }
}
