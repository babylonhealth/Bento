import UIKit
import ReactiveSwift

public protocol FormTableViewDataSourceProtocol: class {
    func removeAll()
}

open class FormTableView: UITableView {
    public var formStyle: FormStyle = .topYAligned {
        didSet {
            if formStyle != oldValue {
                setNeedsLayout()
            }
        }
    }

    public var preferredContentHeight: CGFloat = 0.0 {
        didSet {
            if preferredContentHeight != oldValue {
                setNeedsLayout()
            }
        }
    }

    public var additionalContentInsets: UIEdgeInsets = .zero {
        didSet {
            if additionalContentInsets != oldValue {
                setNeedsLayout()
                deltaForUpdatingContentOffset = CGPoint(x: additionalContentInsets.left,
                                                        y: additionalContentInsets.top)
            }
        }
    }

    internal var keyboardHeight: CGFloat = 0.0 {
        didSet {
            if keyboardHeight != oldValue {
                setNeedsLayout()
            }
        }
    }

    private let animator = UIViewPropertyAnimator(duration: 0.2, curve: .easeInOut, animations: nil)
    private var isTransitioning: Bool = false
    private var transitionTargetStyle: FormStyle!
    private var transitionDidComplete: (() -> Void)? = nil

    private var deltaForUpdatingContentOffset: CGPoint?

    open override func layoutSubviews() {
        super.layoutSubviews()
        updateScrollViewParameters()
    }

    /// Transition the form table view to the specified style.
    ///
    /// If multiple transition attempts are raised during an on-going fade-out
    /// animation, only the style and the completion callback of the last
    /// attempt would be honoured.
    ///
    /// The completion callback would be invoked immediately if no transition
    /// needs to be performed.
    ///
    /// The data source and its batch updating logic must react properly to
    /// `FormTableViewDataSourceProtocol.removeAll()`, which is invoked by the
    /// `FormTableView` to purge all existing items as part of the form style
    /// transition.
    ///
    /// - parameters:
    ///   - style: The target form style.
    ///   - completion: The completion callback to invoke when the target form
    ///                 style has been applied.
    public func transition(to style: FormStyle, completion: @escaping () -> Void) {
        let shouldAnimate = formStyle != style

        if shouldAnimate.isFalse && transitionDidComplete.isNil {
            completion()
            return
        }

        transitionTargetStyle = style
        transitionDidComplete = completion

        if isTransitioning.isFalse {
            isTransitioning = true

            // Quickly fade out the UITableView to prepare for a form style change.
            animator.addAnimations { self.alpha = 0.0 }

            animator.addCompletion { _ in
                // Clear the table view content immediately.
                (self.dataSource as? FormTableViewDataSourceProtocol)?.removeAll()
                self.reloadData()
                self.layoutIfNeeded()

                self.alpha = 1.0

                // The form style should only be updated after the table view
                // has faded out.
                self.formStyle = self.transitionTargetStyle
                self.updateScrollViewParameters()

                self.transitionDidComplete?()
                self.transitionDidComplete = nil
                self.isTransitioning = false
            }

            animator.startAnimation()
        }
    }

    private func updateScrollViewParameters() {
        let topInset: CGFloat

        switch formStyle {
        case .topYAligned:
            topInset = additionalContentInsets.top
        case .centerYAligned:
            topInset = (preferredContentHeight - contentSize.height) * 0.5 + additionalContentInsets.top
        }

        contentInset = UIEdgeInsets(top: topInset,
                                    left: additionalContentInsets.left,
                                    bottom: additionalContentInsets.bottom + keyboardHeight,
                                    right: additionalContentInsets.right)
        scrollIndicatorInsets = contentInset

        if let delta = deltaForUpdatingContentOffset {
            deltaForUpdatingContentOffset = nil
            contentOffset = CGPoint(x: -delta.x, y: -delta.y)
        }
    }
}
