import UIKit

public protocol Renderable: Equatable {
    associatedtype View

    var reuseIdentifier: String { get }

    func generate() -> View
    func render(in view: View)
}

public extension Renderable where Self: AnyObject {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs === rhs
    }
    
    func reload() {
        didChange?()
    }
}

extension Renderable where Self: AnyObject {
    var didChange: (() -> Void)? {
        set {
            objc_setAssociatedObject(self,
                                     AssociatedKey.key,
                                     Value(newValue),
                                     .OBJC_ASSOCIATION_RETAIN);
        }
        get {
            guard let value = objc_getAssociatedObject(self, AssociatedKey.key)
                as? Value<(() -> Void)?> else {
                return nil
            }
            return value.value
        }
    }
}

public extension Renderable {
    var reuseIdentifier: String {
        return String(reflecting: View.self)
    }
}

public extension Renderable where View: UIView {
    func generate() -> View {
        return View()
    }
}

public extension Renderable where View: UIView & NibLoadable {
    func generate() -> View {
        return View.loadFromNib()
    }
}

private struct AssociatedKey {
    static let key = UnsafeMutablePointer<CChar>.allocate(capacity: 1)
}
