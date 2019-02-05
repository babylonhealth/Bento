import Foundation

/// Represent a bunch of properties to be applied to the given view.
public struct StyleSheet<View>: Equatable {
    public typealias Inverse = StyleSheet<View>
    
    private var nodes: [AnyPartialWritableKeyPath: Any]

    public init() {
        nodes = [:]
    }

    @discardableResult
    public func apply(to view: inout View) -> Inverse {
        defer {
            nodes.forEach { keyPath, value in keyPath.wrapped.apply(to: &view, erasedValue: value) }
        }
        
        return StyleSheet().with {
            $0.nodes = Dictionary(
                uniqueKeysWithValues: self.nodes
                    .map { keyPath, value in (keyPath, keyPath.wrapped.current(in: view)) }
            )
        }
    }

    /// Retrieve the value at the specific key path.
    public func value<Value: Equatable>(for keyPath: WritableKeyPath<View, Value>) -> Value? {
        let keyPath = AnyPartialWritableKeyPath(keyPath)
        return nodes[keyPath] as! Value?
    }
    
    // `with` + `set` leads to less transient CoW dictionary allocation.
    /// Set the specified key path to the given value.
    public mutating func set<Value: Equatable>(_ keyPath: WritableKeyPath<View, Value>, _ newValue: Value) {
        let keyPath = AnyPartialWritableKeyPath(keyPath)
        nodes[keyPath] = newValue
    }

    public mutating func removeValue<Value: Equatable>(for keyPath: WritableKeyPath<View, Value>) {
        nodes.removeValue(forKey: AnyPartialWritableKeyPath(keyPath))
    }
    
    public func with(_ action: (inout StyleSheet<View>) -> Void) -> StyleSheet<View> {
        var newSheet = self
        action(&newSheet)
        return newSheet
    }
    
    public func setting<Value: Equatable>(_ keyPath: WritableKeyPath<View, Value>, _ value: Value) -> StyleSheet<View> {
        return with { $0.set(keyPath, value) }
    }

    public static func == (lhs: StyleSheet<View>, rhs: StyleSheet<View>) -> Bool {
        return lhs.nodes.keys == rhs.nodes.keys
            && lhs.nodes.keys.allSatisfy { keyPath in
                keyPath.wrapped.areEqual(lhs.nodes[keyPath]!, rhs.nodes[keyPath]!)
            }
    }
}

private struct AnyPartialWritableKeyPath: Hashable {
    let wrapped: PartialWritableKeyPath

    init(_ wrapped: PartialWritableKeyPath) {
        self.wrapped = wrapped
    }

    static func == (lhs: AnyPartialWritableKeyPath, rhs: AnyPartialWritableKeyPath) -> Bool {
        return lhs.wrapped.keyPath == rhs.wrapped.keyPath
    }

    func hash(into hasher: inout Hasher) {
        wrapped.keyPath.hash(into: &hasher)
    }
}

private protocol PartialWritableKeyPath {
    var keyPath: AnyKeyPath { get }

    func apply<AssertedRoot>(to root: inout AssertedRoot, erasedValue: Any)
    func current<AssertedRoot>(in root: AssertedRoot) -> Any
    func areEqual(_ lhs: Any, _ rhs: Any) -> Bool
}

extension WritableKeyPath: PartialWritableKeyPath where Value: Equatable {
    var keyPath: AnyKeyPath {
        return self
    }

    func apply<AssertedRoot>(to root: inout AssertedRoot, erasedValue: Any) {
        root[keyPath: coerced()] = erasedValue as! Value
    }

    func current<AssertedRoot>(in root: AssertedRoot) -> Any {
        return root[keyPath: coerced()]
    }

    func areEqual(_ lhs: Any, _ rhs: Any) -> Bool {
        guard let lhs = lhs as? Value, let rhs = rhs as? Value else {
            return false
        }

        return lhs == rhs
    }

    private func coerced<AssertedRoot>() -> WritableKeyPath<AssertedRoot, Value> {
        precondition(AssertedRoot.self is Root.Type, "")
        return unsafeDowncast(self, to: WritableKeyPath<AssertedRoot, Value>.self)
    }
}
