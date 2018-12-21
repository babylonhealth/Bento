import Foundation

/// Represent a bunch of properties to be applied to the given view.
public struct StyleSheet<View>: Equatable {
    public typealias Inverse = StyleSheet<View>
    
    private var nodes: [PartialKeyPath<View>: ErasedProperty<View>]

    public init() {
        nodes = [:]
    }

    @discardableResult
    public func apply(to view: inout View) -> Inverse {
        defer {
            nodes.forEach { $0.value.apply(to: &view) }
        }
        
        return StyleSheet().with {
            $0.nodes = self.nodes.mapValues { $0.current(in: view) }
        }
    }

    /// Retrieve the value at the specific key path.
    public func value<Value: Equatable>(for keyPath: WritableKeyPath<View, Value>) -> Value? {
        return (nodes[keyPath] as! KeyedProperty<View, Value>?)?.value
    }
    
    // `with` + `set` leads to less transient CoW dictionary allocation.
    /// Set the specified key path to the given value.
    public mutating func set<Value: Equatable>(_ keyPath: WritableKeyPath<View, Value>, _ newValue: Value) {
        nodes[keyPath] = KeyedProperty(keyPath: keyPath, value: newValue)
    }

    public mutating func removeValue<Value>(for keyPath: WritableKeyPath<View, Value>) {
        nodes.removeValue(forKey: keyPath)
    }
    
    public func with(_ action: (inout StyleSheet<View>) -> Void) -> StyleSheet<View> {
        var newSheet = self
        action(&newSheet)
        return newSheet
    }
    
    public func setting<Value: Equatable>(_ keyPath: WritableKeyPath<View, Value>, _ value: Value) -> StyleSheet<View> {
        return with { $0.set(keyPath, value) }
    }
}

/// Represent a typed value pending application in a style sheet.
private final class KeyedProperty<Root, Value: Equatable>: ErasedProperty<Root> {
    let keyPath: WritableKeyPath<Root, Value>
    let value: Value
    
    init(keyPath: WritableKeyPath<Root, Value>, value: Value) {
        self.keyPath = keyPath
        self.value = value
    }
    
    override func apply(to root: inout Root) {
        root[keyPath: keyPath] = value
    }
    
    override func current(in root: Root) -> Self {
        return type(of: self).init(keyPath: keyPath, value: root[keyPath: keyPath])
    }
    
    override func equal(to other: ErasedProperty<Root>) -> Bool {
        guard let other = other as? KeyedProperty<Root, Value>, keyPath == other.keyPath else {
            return false
        }
        
        return value == other.value
    }
}

/// Value-type-erased base class of `KeyedProperty`, allowing style sheets to carry
/// and manipulate collections of heterogeneous values.
private class ErasedProperty<Root>: Equatable {
    func apply(to root: inout Root) {
        fatalError()
    }
    
    func equal(to other: ErasedProperty<Root>) -> Bool {
        fatalError()
    }
    
    func current(in root: Root) -> Self {
        fatalError()
    }
    
    static func == (lhs: ErasedProperty<Root>, rhs: ErasedProperty<Root>) -> Bool {
        return lhs.equal(to: rhs)
    }
}
