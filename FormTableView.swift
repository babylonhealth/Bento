import UIKit

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

    private let animator: UIViewPropertyAnimator = {
        let animator = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut, animations: nil)
        return animator
    }()

    private var wantsAnimatedInsetChange = false
    private var hasEnqueuedAnimationCallback = false
    private var deltaForUpdatingContentOffset: CGPoint?

    open override func layoutSubviews() {
        super.layoutSubviews()

        guard wantsAnimatedInsetChange else {
            return updateScrollViewParameters()
        }

        // Since the content size might change due to the UITableView self
        // sizing mechaism, we must modify the animation upon any new layout
        // pass.

        animator.addAnimations {
            self.updateScrollViewParameters()
        }

        if !hasEnqueuedAnimationCallback {
            hasEnqueuedAnimationCallback = true
            animator.addCompletion { _ in
                self.wantsAnimatedInsetChange = false
                self.hasEnqueuedAnimationCallback = false
            }
        }

        animator.startAnimation(afterDelay: 0.0)
    }

    public func setFormStyle(_ style: FormStyle, animated: Bool) {
        let shouldAnimate = formStyle != style && animated
        wantsAnimatedInsetChange = wantsAnimatedInsetChange || shouldAnimate
        formStyle = style
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
