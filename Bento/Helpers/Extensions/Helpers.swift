import UIKit

public protocol NibLoadable {
    static var nib: UINib { get }
}

public extension NibLoadable where Self: UIView {
    static var nib: UINib {
        return UINib(nibName: String(describing: self), bundle: Bundle(for: self))
    }

    static func loadFromNib() -> Self {
        return nib.instantiate(withOwner: nil, options: nil).first as! Self
    }
}

extension Optional {
    func zip<T, R>(with other: T?, _ selector: (Wrapped, T) -> R) -> Optional<R> {
        guard let unwrapped = self, let other = other else {
            return nil
        }
        return selector(unwrapped, other)
    }
}

internal func search<T>(from leaf: UIView, type: T.Type) -> T? {
    var cell = leaf.superview
    while let view = cell, !(view is T) {
        cell = view.superview
    }
    return cell as! T?
}

internal func const<T, U, Value>(_ value: Value) -> (_: T, _: U) -> Value {
    return { _, _ in value }
}
