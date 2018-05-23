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
}

public extension Renderable {
    var reuseIdentifier: String {
        /// Returns the demangled qualified name of View
        return _typeName(View.self, qualified: true)
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
