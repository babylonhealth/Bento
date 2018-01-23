public class AnyRenderable {

    let reuseIdentifier: String
    private let renderingGenerator: () -> UIView
    private let updatingGenerator: (UIView) -> Void

    init<R: Renderable>(renderable: R) {
        self.reuseIdentifier = renderable.reuseIdentifier
        self.renderingGenerator = { renderable.render() }
        self.updatingGenerator = { (view) in renderable.update(view: (view as! R.View)) }
    }

    func render() -> UIView {
        return renderingGenerator()
    }

    func update(view: UIView) {
        updatingGenerator(view)
    }
}

public struct FormItem<Identifier: Hashable> {
    /// The identifier of `self`, or `nil` if `self` represents an empty space.
    public let id: Identifier?

    /// The form component backing `self`.
    public let component: AnyRenderable

    /// Initialise a form item.
    ///
    /// - parameters:
    ///   - id: The identifier of the item. `nil` is provisioned for empty spaces and
    ///         should generally be avoided.
    ///   - component: The form component backing the item.
    public init(id: Identifier?, component: AnyRenderable) {
        self.id = id
        self.component = component
    }

    public init<R: Renderable>(id: Identifier?, component: R) {
        self.init(id: id, component: AnyRenderable(renderable: component))
    }
}
