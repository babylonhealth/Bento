import UIKit
import ReactiveSwift

open class BentoTableView: UITableView {
    public var formStyle: Layout = .topYAligned {
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

    public var keyboardFrame: CGRect = .zero {
        didSet {
            if keyboardFrame != oldValue {
                setNeedsLayout()
            }
        }
    }

    private let fadeOut = UIViewPropertyAnimator(duration: 0.15, curve: .easeInOut, animations: nil)
    private let fadeIn = UIViewPropertyAnimator(duration: 0.15, curve: .easeInOut, animations: nil)

    private var isTransitioning: Bool = false
    private var transitionTargetStyle: Layout!
    private var transitionDidComplete: ((_ willReload: Bool) -> Void)? = nil
    private var transitionRemoveAll: (() -> Void)? = nil

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
    /// `removeAll` callback, which is invoked by the
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
    public func transition(to style: Layout, removeAll: @escaping (() -> Void), completion: @escaping (_ willReload: Bool) -> Void) {
        let oldStyle = self.formStyle

        if style.shouldFade(from: oldStyle) == false && isTransitioning == false {
            completion(false)
            return
        }

        transitionTargetStyle = style
        transitionDidComplete = completion
        transitionRemoveAll = removeAll

        if isTransitioning == false {
            isTransitioning = true

            // Quickly fade out the UITableView to prepare for a form style change.
            fadeOut.addAnimations { self.alpha = 0.0 }

            fadeOut.addCompletion { _ in
                // Clear the table view content immediately.
                self.transitionRemoveAll?()
                self.reloadData()
                self.layoutIfNeeded()

                // The form style should only be updated after the table view
                // has faded out.
                self.formStyle = self.transitionTargetStyle

                if self.formStyle.shouldFade(from: oldStyle) || self.isEmpty {
                    // Inform the callback to update the data source without
                    // triggering any animation.
                    self.transitionDidComplete?(true)
                    self.transitionDidComplete = nil
                    self.transitionRemoveAll = nil

                    self.contentInset = .zero

                    self.reloadData()
                    self.layoutIfNeeded()
                    self.updateScrollViewParameters()

                    if #available(iOS 11, *) {
                        // The content offset is auto-adjusted correctly under iOS 11.
                    } else {
                        self.contentOffset = CGPoint(x: 0, y: -self.contentInset.top)
                    }

                    // Fade in the UITableView.
                    self.fadeIn.addAnimations { self.alpha = 1.0 }
                    self.fadeIn.addCompletion { _ in
                        self.markTransitionAsCompleted()
                    }
                    self.fadeIn.startAnimation()
                } else {
                    self.alpha = 1.0
                    self.contentInset = .zero

                    // Hand over an empty UITableView to the callback.
                    self.transitionDidComplete?(false)
                    self.transitionDidComplete = nil
                    self.transitionRemoveAll = nil

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
        precondition(isTransitioning == false)
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
            let completion = transitionDidComplete,
            let removeAll = transitionRemoveAll {
            transition(to: style, removeAll: removeAll, completion: completion)
        }
    }

    private func updateScrollViewParameters() {
        let topInset: CGFloat
        let viewFrame = convert(bounds, to: nil)
        let boundedKeyboardHeight = viewFrame.intersection(keyboardFrame).height

        switch formStyle {
        case .topYAligned, .topYAlignedAlwaysFading:
            topInset = additionalContentInsets.top
        case .centerYAligned, .centerYAlignedMinimumFading:
            topInset = max((preferredContentHeight - contentSize.height - boundedKeyboardHeight) * 0.5, 0.0) + additionalContentInsets.top
        }

        // `topInset` must be rounded to ensure pixel perfectness and prevent
        // jittering due to pixel misalignment.
        let proposedContentInset = UIEdgeInsets(top: topInset.rounded(),
                                                left: additionalContentInsets.left,
                                                bottom: max(additionalContentInsets.bottom, boundedKeyboardHeight),
                                                right: additionalContentInsets.right)

        if proposedContentInset != contentInset {
            contentInset = proposedContentInset
            scrollIndicatorInsets = proposedContentInset
        }

        if let delta = deltaForUpdatingContentOffset {
            deltaForUpdatingContentOffset = nil
            contentOffset = CGPoint(x: -delta.x, y: -delta.y)
        }
    }
}

extension BentoTableView: MultilineTextInputAware {
    @objc public func multilineTextInputHeightDidChange(_ sender: Any) {
        UIView.setAnimationsEnabled(false)
        beginUpdates()
        endUpdates()
        UIView.setAnimationsEnabled(true)

        func searchCellContainer(of view: UIView) -> UITableViewCell? {
            if let cell = view as? UITableViewCell {
                return cell
            }
            return view.superview.flatMap(searchCellContainer)
        }

        guard let view = sender as? UIView,
            view.isDescendant(of: self),
            let containingCell = searchCellContainer(of: view),
            let indexPath = indexPath(for: containingCell)
            else { return }

        self.scrollToRow(at: indexPath, at: .bottom, animated: false)
    }
}

extension BentoTableView {
    fileprivate var isEmpty: Bool {
        // Bento may have zero section. Forms have always one section, but the
        // section may contain zero row.
        return numberOfSections == 0
            || numberOfSections == 1 && numberOfRows(inSection: 0) == 0
    }
}

extension BentoTableView {
    /// Represent how `FormTableView` should place its content against the safe area
    /// and how it should animate delta changes.
    ///
    /// Unless otherwise specified, the fading behavior always applies. That is,
    /// whenever changes occur and regardless of the target form style, the entirety
    /// of the content would be faded out, updated, and then faded back in.
    ///
    /// For the `topYAligned` style, if the originated and target styles are both
    /// `topYAligned`, the general container view delta animation applies.
    /// Otherwise, the aforementioned fading behavior applies.
    public enum Layout {
        /// The content bound should align to the top of the safe area.
        ///
        /// If the originated and target styles are both `topYAligned`, the general
        /// container view delta animation applies. Otherwise, the fading behavior
        /// as mentioned in `FormStyle` applies.
        ///
        /// - important: This is the default style for transitions.
        case topYAligned

        /// The content bound should align to the top of the safe area.
        ///
        /// On contrary to `topYAligned`, the fading behavior always applies.
        case topYAlignedAlwaysFading

        /// The content bound should be vertically aligned to the center of the safe
        /// area.
        ///
        /// The fading behavior always applies for `centerYAligned`.
        case centerYAligned

        /// The content bound should be vertically aligned to the center of the safe
        /// area.
        ///
        /// The fading behavior applies only when transitioning from or to
        /// `topYAligned(AlwaysFading)?`.
        case centerYAlignedMinimumFading

        func shouldFade(from previous: Layout) -> Bool {
            switch (previous, self) {
            case (_, .centerYAligned),
                 (.centerYAligned, .topYAligned),
                 (.topYAlignedAlwaysFading, _),
                 (_, .topYAlignedAlwaysFading),
                 (.centerYAlignedMinimumFading, .topYAligned),
                 (.topYAligned, .centerYAlignedMinimumFading),
                 (.centerYAligned, .centerYAlignedMinimumFading):
                return true
            case (_, .topYAligned), (_, .centerYAlignedMinimumFading):
                return false
            }
        }
    }
}

