import UIKit

public protocol StyleSheetProtocol {
    associatedtype Element

    func apply(to element: Element)
}

extension StyleSheetProtocol {
    @discardableResult
    public func compose<T>(_ property: ReferenceWritableKeyPath<Self, T>, _ value: T) -> Self {
        self[keyPath: property] = value
        return self
    }

    @discardableResult
    public func compose<T>(_ property: ReferenceWritableKeyPath<Self, T?>, _ value: T?) -> Self {
        self[keyPath: property] = value
        return self
    }
}

extension NSObjectProtocol {
    func with(_ action: (inout Self) -> Void) -> Self {
        var object = self
        action(&object)
        return object
    }
}
