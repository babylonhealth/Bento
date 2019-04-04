import UIKit

/// Protocol which every Component needs to conform to.
/// - View: UIView subtype which is the top level view type of the component.
public protocol Renderable {
    associatedtype View: NativeView

    func render(in view: View)
}

public extension Renderable {
    func asAnyRenderable() -> AnyRenderable {
        return AnyRenderable(self)
    }

    func deletable(
        deleteActionText: String,
        backgroundColor: UIColor? = nil,
        didDelete: @escaping () -> Void
    ) -> AnyRenderable {
        return DeletableComponent(
            source: self,
            deleteActionText: deleteActionText,
            backgroundColor: backgroundColor,
            didDelete: didDelete
        ).asAnyRenderable()
    }

    func on(willDisplayItem: (() -> Void)? = nil, didEndDisplayingItem: (() -> Void)? = nil) -> AnyRenderable {
        return LifecycleComponent(
            source: self,
            willDisplayItem: willDisplayItem,
            didEndDisplayingItem: didEndDisplayingItem
        ).asAnyRenderable()
    }
}
