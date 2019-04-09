import UIKit

/// A type that can be used as a component in a Bento box.
public protocol Renderable {
    /// The reusable view type that the component uses for rendering its content.
    associatedtype View: NativeView

    /// Render the content of `self` into `view`.
    func render(in view: View)

    /// Produce a performance hint for Bento to better decide its view reusability strategy.
    ///
    /// Note that having a reusability hint **does not imply** that Bento would always only reuse views when the
    /// reusability hint matches. In other words, you **must still ensure** your composite component view handles type
    /// mismatches in the view hierarchy correctly and gracefully.
    ///
    /// For example, if you have a composite component that has a small but fixed number of combinations of child
    /// components, you may implement this requirement to improve the performance, which otherwise would involve
    /// time in recreating views as they are queued to go on screen.
    ///
    /// ```swift
    /// struct CompositeComponent: Renderable {
    ///     let children: [AnyRenderable]
    ///
    ///     func render(in view: View) {
    ///         // Logic to recreate the view hierarchy if types and orders of components do not match
    ///     }
    ///
    ///     func makeReusabilityHint(using combiner: inout ReusabilityHintCombiner) {
    ///         children.forEach { combiner.combine($0) }
    ///     }
    /// }
    ///
    /// // NOTE: These combinations would all result in different reusability hints.
    /// //       (Assuming there are three component types `A`, `B`, and `C`.
    /// CompositeComponent(children: [])
    /// CompositeComponent(children: [A()])
    /// CompositeComponent(children: [B()])
    /// CompositeComponent(children: [C()])
    /// CompositeComponent(children: [A(), B()])
    /// CompositeComponent(children: [A(), C()])
    /// CompositeComponent(children: [B(), A()])
    /// CompositeComponent(children: [B(), C()])
    /// CompositeComponent(children: [C(), A()])
    /// CompositeComponent(children: [C(), B()])
    /// CompositeComponent(children: [A(), B(), C()])
    /// CompositeComponent(children: [A(), C(), B()])
    /// CompositeComponent(children: [B(), A(), C()])
    /// CompositeComponent(children: [B(), C(), A()])
    /// CompositeComponent(children: [C(), A(), B()])
    /// CompositeComponent(children: [C(), B(), A()])
    /// ```
    ///
    /// - important: The order of `combiner.combine(_:)` matters.
    ///
    /// - important: Bento always considers the component type for view reusability. So components need not combine
    ///              its own type again.
    ///
    /// - note: This is an optional requirement intended for composite components that contain children components
    ///         or dynamic view hierarchies.
    ///
    /// - parameters:
    ///   - combiner: The combiner to concatenate all relevant information that affects reusability.
    func makeReusabilityHint(using combiner: inout ReusabilityHintCombiner)
}

public extension Renderable {
    func makeReusabilityHint(using combiner: inout ReusabilityHintCombiner) {}

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

internal extension Renderable {
    var componentType: Any.Type {
        return (self as? AnyRenderable)?.componentType
            ?? type(of: self)
    }

    var reusabilityHintCombiner: ReusabilityHintCombiner {
        var combiner = ReusabilityHintCombiner(root: self)
        makeReusabilityHint(using: &combiner)
        return combiner
    }

    var reuseIdentifier: String {
        return reusabilityHintCombiner.generate()
    }
}
