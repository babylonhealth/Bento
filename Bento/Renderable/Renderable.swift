import UIKit

/// Represent a component that can be rendered on screen as part of a composite
/// layout tree.
public protocol Renderable {
    associatedtype View

    var reuseIdentifier: String { get }

    func generate() -> View
    func render(in view: View)
    
    /// Whether `lhs` and `rhs` produces an equivalent layout.
    ///
    /// Components may implement this method if they are able to determine whether
    /// two instances should produce equivalent layout result solely based on the
    /// component properties.
    ///
    /// The default implementation returns `false`, leading Bento to be conservative
    /// about re-rendering elision and other optimizations.
    static func isLayoutEquivalent(_ lhs: Self, _ rhs: Self) -> Bool
}

public extension Renderable {
    static func isLayoutEquivalent(_ lhs: Self, _ rhs: Self) -> Bool {
        return false
    }
    
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
