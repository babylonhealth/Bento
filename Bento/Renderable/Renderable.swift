import UIKit

/// Protocol which every Component needs to conform to.
/// - View: UIView subtype which is the top level view type of the component.
public protocol Renderable {
    associatedtype View: NativeView

    /// Render the component into a host native view.
    ///
    /// - important: For all key paths being potentially touched by the component, they must all be consistently
    ///              overwritten regardless of what conditional branches the component have taken internally.
    ///
    /// - parameters:
    ///   - view: The host native view to render to.
    func render(in view: View)

    /// Acknowledge that the component has been mounted to a host native view.
    ///
    /// - warning: If any manipulation on `view` is performed here, it must be undone in `willUnmount(from:storage:)`.
    ///
    /// - parameters:
    ///   - view: The host native view the component has been mounted with.
    ///   - storage: The view storage in which additional dynamic data can be stored.
    func didMount(to view: View, storage: ViewStorage)

    /// Acknowledge that the component is about to be unmounted from a host native view.
    ///
    /// - warning: If any manipulation on `view` has been performed in `didMount(to:storage:)`, it must be undone here.
    ///
    /// - parameters:
    ///   - view: The host native view the component is to be unmounted from.
    ///   - storage: The view storage with additional dynamic data from `didMount(to:storage:)`.
    func willUnmount(from view: View, storage: ViewStorage)
}

extension Renderable {
    public func asAnyRenderable() -> AnyRenderable {
        return AnyRenderable(self)
    }

    public func didMount(to view: View, storage: ViewStorage) {}
    public func willUnmount(from view: View, storage: ViewStorage) {}
}
