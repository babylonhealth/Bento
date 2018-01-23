import Foundation

public protocol Renderable: class {
    associatedtype View: UIView
    var strategy: RenderingStrategy { get }
    func render(in view: View)
}

public extension Renderable {
    var reuseIdentifier: String {
        return String(describing: View.self)
    }
}

public enum RenderingStrategy {
    case `class`
    case nib
}
