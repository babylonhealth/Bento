import UIKit

/// An interactive `UIView` that can become a first responder.
open class InteractiveView: BaseView {
    open override var canBecomeFirstResponder: Bool {
        return true
    }

    /// The highlighting gesture recognizer for `self`. This gesture recognizer
    /// is instantiated lazily upon first access.
    public private(set) lazy var highlightingGesture = HighlightingGesture()
        .with { self.addGestureRecognizer($0) }
}

/// An interactive `UIStackView` that can become a first responder.
open class InteractiveStackView: BaseStackView {
    open override var canBecomeFirstResponder: Bool {
        return true
    }

    /// The highlighting gesture recognizer for `self`. This gesture recognizer
    /// is instantiated lazily upon first access.
    public private(set) lazy var highlightingGesture = HighlightingGesture()
        .with { self.addGestureRecognizer($0) }
}
