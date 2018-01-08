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

    internal var keyboardFrame: CGRect = .zero {
        didSet {
            if keyboardFrame != oldValue {
                setNeedsLayout()
            }
        }
    }

    private let fadeOut = UIViewPropertyAnimator(duration: 0.15, curve: .easeInOut, animations: nil)
    private let fadeIn = UIViewPropertyAnimator(duration: 0.15, curve: .easeInOut, animations: nil)

    private var isTransitioning: Bool = false
    private var transitionTargetStyle: FormStyle!
    private var transitionDidComplete: ((_ willReload: Bool) -> Void)? = nil

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
    /// The table view might inform the completion callback with an asserted
    /// flag of its intent to reload afterwards. The callback is advised to
    /// update the data source and avoid calling any UITableView method.
    ///
    /// - parameters:
    ///   - style: The target form style.
    ///   - completion: The completion callback to invoke when the target form
    ///                 style has been applied.
    public func transition(to style: FormStyle, completion: @escaping (_ willReload: Bool) -> Void) {
        if formStyle == style && style.alwaysFades.isFalse && isTransitioning.isFalse {
            completion(false)
            return
        }

        transitionTargetStyle = style
        transitionDidComplete = completion

        if isTransitioning.isFalse {
            isTransitioning = true

            // Quickly fade out the UITableView to prepare for a form style change.
            fadeOut.addAnimations { self.alpha = 0.0 }

            fadeOut.addCompletion { _ in
                // Clear the table view content immediately.
                (self.dataSource as? FormTableViewDataSourceProtocol)?.removeAll()
                self.reloadData()
                self.layoutIfNeeded()

                // The form style should only be updated after the table view
                // has faded out.
                self.formStyle = self.transitionTargetStyle
                self.updateScrollViewParameters()

                if self.formStyle.alwaysFades {
                    // Inform the callback to update the data source without
                    // triggering any animation.
                    self.transitionDidComplete?(true)
                    self.transitionDidComplete = nil
                    self.reloadData()

                    // Fade in the UITableView.
                    self.fadeIn.addAnimations { self.alpha = 1.0 }
                    self.fadeIn.addCompletion { _ in
                        self.markTransitionAsCompleted()
                    }
                    self.fadeIn.startAnimation()
                } else {
                    self.alpha = 1.0

                    // Hand over an empty UITableView to the callback.
                    self.transitionDidComplete?(false)
                    self.transitionDidComplete = nil
                    self.markTransitionAsCompleted()
                }
            }

            fadeOut.startAnimation()
        }
    }

    public func deleteRowForSwipeAction(
        at indexPath: IndexPath,
        contextCompletion: ((Bool) -> Void)? = nil,
        completion: @escaping () -> Void
    ) {
        precondition(isTransitioning.isFalse)
        isTransitioning = true

        CATransaction.begin()
        CATransaction.setCompletionBlock {
            self.markTransitionAsCompleted()
            completion()
        }

        deleteRows(at: [indexPath], with: .automatic)
        contextCompletion?(true)

        CATransaction.commit()
    }

    private func markTransitionAsCompleted() {
        isTransitioning = false

        // Start a transition if a transition attempt is
        // recorded during the fading in animation.
        if let style = transitionTargetStyle,
           let completion = transitionDidComplete {
            transition(to: style, completion: completion)
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

        let viewFrame = convert(bounds, to: nil)
        let boundedKeyboardHeight = viewFrame.intersection(keyboardFrame).height
        let actualKeyboardInset = max(boundedKeyboardHeight - max(viewFrame.height - boundedKeyboardHeight - contentSize.height, 0), 0)

        contentInset = UIEdgeInsets(top: topInset,
                                    left: additionalContentInsets.left,
                                    bottom: additionalContentInsets.bottom + actualKeyboardInset,
                                    right: additionalContentInsets.right)
        scrollIndicatorInsets = contentInset

        if let delta = deltaForUpdatingContentOffset {
            deltaForUpdatingContentOffset = nil
            contentOffset = CGPoint(x: -delta.x, y: -delta.y)
        }
    }
}

fileprivate extension FormStyle {
    var alwaysFades: Bool {
        switch self {
        case .centerYAligned:
            return true
        case .topYAligned:
            return false
        }
    }
}
