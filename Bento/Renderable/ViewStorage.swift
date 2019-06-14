public struct ViewStorage {
    internal let componentType: Any.Type
    internal let view: BentoReusableView

    internal init(componentType: Any.Type, view: BentoReusableView) {
        self.componentType = componentType
        self.view = view
    }

    public subscript<Value>(key: Key<Value>) -> Value? {
        get {
            let key = StorageKey(component: componentType, identifier: key.identifier)
            return view.storage[key] as! Value?
        }
        nonmutating set {
            let key = StorageKey(component: componentType, identifier: key.identifier)
            view.storage[key] = newValue
        }
    }
}

extension ViewStorage {
    public struct Key<Value>: Hashable {
        var identifier: ObjectIdentifier {
            return ObjectIdentifier(object)
        }

        private let object: AnyObject

        /// Create a unique view storage key.
        public init() {
            object = Token()
        }

        /// Create a view storage key from a metatype.
        public init(_ type: Any.Type) {
            object = type as AnyObject
        }

        public func hash(into hasher: inout Hasher) {
            hasher.combine(identifier)
        }

        public static func == (lhs: Key<Value>, rhs: Key<Value>) -> Bool {
            return lhs.object === rhs.object
        }

        private final class Token {}
    }
}
