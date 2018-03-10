import UIKit

public protocol Renderable: class {
    associatedtype View

    func generate() -> View
    func render(in view: View)
}

public extension Renderable {
    var reuseIdentifier: String {
        return String(describing: View.self)
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
