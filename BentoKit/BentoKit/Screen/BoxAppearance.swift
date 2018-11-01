import UIKit

/// Represent a set of styling parameters which the screen renderer may use to
/// style its components.
///
/// - warning: You must implement the appearance with value semantics for
///            traits to behave correctly.
public protocol BoxAppearance {
    var traits: UITraitCollection { get set }
}
