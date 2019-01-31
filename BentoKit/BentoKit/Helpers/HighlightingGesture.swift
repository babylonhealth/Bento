import UIKit
import UIKit.UIGestureRecognizerSubclass

public final class HighlightingGesture: UIGestureRecognizer {
    public enum TapAction {
        /// Resign as first responder immediately after tap, and evaluate the
        /// given action. Backgorund would be reset to the normal color.
        case resign(action: () -> Void)

        /// Unhighlighting would happen manually at a later point. Background
        /// shall remain highlighted.
        case manual
    }

    public var isHighlighted: Bool = false {
        didSet {
            highlightingStatusDidChange(from: oldValue, to: isHighlighted)
        }
    }
    public var highlightColor: UIColor? = UIColor(red: 239/255.0, green: 239/255.0, blue: 244/255.0, alpha: 1)
    public var didTap: TapAction? {
        didSet {
            isEnabled = didTap != nil
        }
    }
    public var stylingView: UIView? {
        didSet {
            guard oldValue != stylingView else { return }
            stylingViewDidChange(from: oldValue, to: stylingView)
        }
    }
    public var interactionBehavior: InteractionBehavior = .becomeFirstResponder

    private var normalColor: UIColor?
    private var startPoint = CGPoint.zero

    init() {
        super.init(target: nil, action: nil)
        self.isEnabled = false
        self.delegate = self
        super.addTarget(self, action: #selector(handleTap))
    }

    public func didRebindView() {
        if isHighlighted {
            highlightingStatusDidChange(from: false, to: true)
        }
    }

    @objc func handleTap() {
        if stylingView == nil {
            stylingView = view
        }

        switch state {
        case .possible:
            break;
        case .began:
            isHighlighted = true
        case .changed:
            break
        case .ended:
            if let view = view {
                precondition(view.canBecomeFirstResponder, "`HighlightingGesture` should be used only with views that can become first responder.")

                if interactionBehavior.contains(.becomeFirstResponder) {
                    view.becomeFirstResponder()
                }

                switch didTap {
                case .manual?:
                    break
                case let .resign(action)?:
                    view.resignFirstResponder()
                    action()
                    fallthrough
                case nil:
                    isHighlighted = false
                }
            }
        case .cancelled, .failed:
            isHighlighted = false
        }
    }

    public override func reset() {
        startPoint = .zero
    }

    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        guard touches.count == 1 else {
            state = .failed
            return
        }
        guard let touch = touches.first else { return }

        let location = touch.location(in: view)
        let contains = view?.bounds.contains(location) ?? false
        if contains {
            startPoint = location
            state = .began
        }
    }

    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)
        guard let touch = touches.first else { return }

        let location = touch.location(in: view)

        let diffX = abs(location.x - startPoint.x)
        let diffY = abs(location.y - startPoint.y)

        if diffX > 10 || diffY > 10 {
            state = .cancelled
        }

        let contains = view?.bounds.contains(location) ?? false
        if contains == false {
            state = .cancelled
        }
    }

    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesEnded(touches, with: event)
        guard let touch = touches.first else { return }

        let contains = view?.bounds.contains(touch.location(in: view)) ?? false
        if contains {
            state = .ended
        } else {
            state = .cancelled
        }
    }

    @available(*, unavailable)
    public override func addTarget(_ target: Any, action: Selector) { fatalError() }

    private func highlightingStatusDidChange(from old: Bool, to new: Bool) {
        switch (old, new) {
        case (false, true):
            normalColor = stylingView?.backgroundColor
            stylingView?.backgroundColor = highlightColor
        case (true, false):
            stylingView?.backgroundColor = normalColor
        case (false, false), (true, true):
            break
        }
    }

    private func stylingViewDidChange(from old: UIView?, to new: UIView?) {
        if isHighlighted {
            old?.backgroundColor = normalColor
            normalColor = new?.backgroundColor
            new?.backgroundColor = highlightColor
        }
    }
}

extension HighlightingGesture: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return otherGestureRecognizer is UIPanGestureRecognizer
    }
}
