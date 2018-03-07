import UIKit

public protocol Renderable: class {
    associatedtype View

    func render(in view: View)
}

public extension Renderable {
    var reuseIdentifier: String {
        return String(describing: View.self)
    }
}
