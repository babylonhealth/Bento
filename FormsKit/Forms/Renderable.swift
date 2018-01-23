import Foundation

public protocol Renderable: class {
    associatedtype View: UIView
    func render() -> View
    func update(view: View)
}

public extension Renderable {
    var reuseIdentifier: String {
        return String(describing: View.self)
    }
}

protocol SomeProtocol {
    var onRendering: () -> UIView { get }
    //var onUpdate: (UIView) -> Void { get }
}
