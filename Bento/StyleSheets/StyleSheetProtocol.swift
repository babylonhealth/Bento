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
