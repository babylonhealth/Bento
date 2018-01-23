class AnyRenderable {

    let reuseIdentifier: String
    let generator: () -> UIView
    private let _render: (UIView) -> Void

    init<R: Renderable>(renderable: R) {
        self.reuseIdentifier = renderable.reuseIdentifier
        self.generator = {
            switch renderable.strategy {
            case .`class`: return R.View.init()
            case .nib: return R.View.loadFromNib()
            }
        }
        self._render = { (view) in renderable.render(in: (view as! R.View)) }
    }

    func render(in view: UIView) {
        _render(view)
    }
}

public struct FormItem<Identifier: Hashable> {
    /// The identifier of `self`, or `nil` if `self` represents an empty space.
    public let id: Identifier?

    /// The form component backing `self`.
    let component: AnyRenderable

    /// Initialise a form item.
    ///
    /// - parameters:
    ///   - id: The identifier of the item. `nil` is provisioned for empty spaces and
    ///         should generally be avoided.
    ///   - component: The form component backing the item.
    init(id: Identifier?, component: AnyRenderable) {
        self.id = id
        self.component = component
    }

    public init<R: Renderable>(id: Identifier?, component: R) {
        self.init(id: id, component: AnyRenderable(renderable: component))
    }
}
