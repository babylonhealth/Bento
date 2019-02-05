import Foundation

/// Represent a bunch of properties to be applied to the given view.
public struct StyleSheet<View>: Equatable {
    public typealias Inverse = StyleSheet<View>
    
    private var entries: [EntryKey: Any]
    private var orderedKeys: [EntryKey]

    public init() {
        entries = [:]
        orderedKeys = []
    }

    @discardableResult
    public func apply(to view: inout View) -> Inverse {
        // NOTE: To handle entries with partially overlapping key paths correctly, we apply changes based on the
        //       insertion order, and produce an inverse that applies in the reversed insertion order.
        var inverse = StyleSheet()
        inverse.orderedKeys = orderedKeys.reversed()

        for key in orderedKeys {
            inverse.entries[key] = key.keyPath.current(in: view)
            key.keyPath.unsafeApply(to: &view, erasedValue: entries[key]!)
        }

        return inverse
    }

    /// Retrieve the value at the specific key path.
    public func value<Value: Equatable>(for keyPath: WritableKeyPath<View, Value>) -> Value? {
        let key = EntryKey(keyPath)
        return entries[key] as! Value?
    }

    public mutating func set<Value: Equatable>(_ keyPath: WritableKeyPath<View, Value>, _ newValue: Value) {
        let key = EntryKey(keyPath)
        entries[key] = newValue
        orderedKeys.append(key)
    }

    public mutating func removeValue<Value: Equatable>(for keyPath: WritableKeyPath<View, Value>) {
        let key = EntryKey(keyPath)
        if entries.removeValue(forKey: key) != nil {
            orderedKeys.remove(at: orderedKeys.index(of: key)!)
        }
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
        return lhs.orderedKeys == rhs.orderedKeys
            && lhs.orderedKeys.allSatisfy { key in
                // NOTE: Key paths are equal only when both types and the path completely match. So at this point
                //       invoking `unsafeAreEqual` on either side should not matter, as they are both of the same type.
                key.keyPath.unsafeAreEqual(lhs.entries[key]!, rhs.entries[key]!)
            }
    }
}

/// A wrapper enabling `UnsafePartialWritableKeyPath` to be used as `Dictionary` keys.
private struct EntryKey: Hashable {
    let keyPath: UnsafePartialWritableKeyPath

    init(_ keyPath: UnsafePartialWritableKeyPath) {
        self.keyPath = keyPath
    }

    static func == (lhs: EntryKey, rhs: EntryKey) -> Bool {
        return lhs.keyPath.keyPath == rhs.keyPath.keyPath
    }

    func hash(into hasher: inout Hasher) {
        keyPath.hash(into: &hasher)
    }
}

/// Represent a writable key path that has both its root type and its value type erased.
private protocol UnsafePartialWritableKeyPath: AnyObject {
    var keyPath: AnyKeyPath { get }

    /// Partially mutate the given instance at the key path, i.e. `self`, with the given value.
    ///
    /// - precondition:
    ///   - Function parameter `erasedValue` must be a value of the erased value type of the key path.
    ///   - Type parameter `AssertedRoot` must be the erased root type of the key path.
    ///
    /// - parameters:
    ///   - root: The instance to mutate.
    ///   - erasedValue: The value to apply at the key path, i.e. `self`.
    func unsafeApply<AssertedRoot>(to root: inout AssertedRoot, erasedValue: Any)

    /// Read the current value at the key path, i.e. `self`, in the given instance.
    ///
    /// - precondition:
    ///   - Type parameter `AssertedRoot` must be the erased root type of the key path.
    ///
    /// - parameters:
    ///   - root: The instance to read from.
    ///
    /// - returns: The current value at the key path, type erased.
    func current<AssertedRoot>(in root: AssertedRoot) -> Any

    /// Evaluate whether two values are equal to each other.
    ///
    /// - precondition:
    ///   - Function parameters `lhs` and `rhs` must be a value of the erased value type of the key path.
    ///
    /// - parameters:
    ///   - lhs: The first value to evaluate.
    ///   - rhs: The second value to evaluate.
    ///
    /// - returns: `true` if they are equal. `false` otherwise.
    func unsafeAreEqual(_ lhs: Any, _ rhs: Any) -> Bool

    /// Hash the key path into the given hasher.
    ///
    /// - paramters:
    ///   - hasher: The hasher to hash into.
    func hash(into hasher: inout Hasher)
}

extension WritableKeyPath: UnsafePartialWritableKeyPath where Value: Equatable {
    var keyPath: AnyKeyPath {
        return self
    }

    func unsafeApply<AssertedRoot>(to root: inout AssertedRoot, erasedValue: Any) {
        root[keyPath: coerced()] = erasedValue as! Value
    }

    func current<AssertedRoot>(in root: AssertedRoot) -> Any {
        return root[keyPath: coerced()]
    }

    func unsafeAreEqual(_ lhs: Any, _ rhs: Any) -> Bool {
        return (lhs as! Value) == (rhs as! Value)
    }

    private func coerced<AssertedRoot>() -> WritableKeyPath<AssertedRoot, Value> {
        precondition(AssertedRoot.self is Root.Type, "")
        return unsafeDowncast(self, to: WritableKeyPath<AssertedRoot, Value>.self)
    }
}
