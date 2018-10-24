import Bento

@objc public protocol MultilineTextInputAware where Self: UIView {
    func multilineTextInputHeightDidChange(_ sender: Any)
}

extension Component {
    public final class MultilineTextInput: AutoRenderable, Focusable {
        public let configurator: (View) -> Void
        public let focusEligibility: FocusEligibility
        public let styleSheet: Component.MultilineTextInput.StyleSheet

        public init(text: String, placeholder: String, didFinishEditing: @escaping (String) -> Void, styleSheet: StyleSheet) {
            self.configurator = { view in
                view.textView.text = text
                view.placeholderLabel.text = placeholder
                view.placeholderLabel.isHidden = text.isEmpty == false
                view.didFinishEditing = didFinishEditing
            }
            self.focusEligibility = text.isEmpty == false ? .eligible(.populated) : .eligible(.empty)
            self.styleSheet = styleSheet
        }
    }
}

extension Component.MultilineTextInput {
    @objc(ComponentMultilineTextInputView)
    public final class View: BaseView, FocusableView {
        let textView = UITextView().with {
            $0.isScrollEnabled = false
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.setContentHuggingPriority(.cellRequired, for: .vertical)
            $0.setContentCompressionResistancePriority(.cellRequired, for: .vertical)
            $0.textContainerInset = .zero
            $0.textContainer.lineFragmentPadding = 0.0
        }

        let placeholderLabel = UILabel()
        var didFinishEditing: ((String) -> Void)?

        private var lastKnownContentHeight: CGFloat = 0.0

        public override init(frame: CGRect) {
            super.init(frame: frame)

            textView.delegate = self
            textView.add(to: self).pinEdges(to: layoutMarginsGuide)

            addSubview(placeholderLabel)
            placeholderLabel.translatesAutoresizingMaskIntoConstraints = false

            // Pin the placeholder label to the layout margins guide. The bottom
            // edge should have lower priority than 1000 so that the UITextView
            // can take precedence when the content height is being determined.
            NSLayoutConstraint.activate([
                layoutMarginsGuide.topAnchor.constraint(equalTo: placeholderLabel.topAnchor),
                layoutMarginsGuide.leadingAnchor.constraint(equalTo: placeholderLabel.leadingAnchor),
                layoutMarginsGuide.trailingAnchor.constraint(equalTo: placeholderLabel.trailingAnchor),
                layoutMarginsGuide.bottomAnchor.constraint(equalTo: placeholderLabel.bottomAnchor)
                    .withPriority(.defaultHigh),
            ])
        }

        @available(*, unavailable)
        public required init?(coder aDecoder: NSCoder) { fatalError() }
    }
}

extension Component.MultilineTextInput.View {
    public func focus() {
        textView.becomeFirstResponder()
    }

    public func neighboringFocusEligibilityDidChange() {
        (textView.inputAccessoryView as? FocusToolbar)?.updateFocusEligibility(with: self)
        textView.reloadInputViews()
    }
}

extension Component.MultilineTextInput.View: UITextViewDelegate {
    public func textViewDidEndEditing(_ textView: UITextView) {
        didFinishEditing?(textView.text)
        textView.inputAccessoryView = nil
    }

    public func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = textView.text.isEmpty == false

        if textView.intrinsicContentSize.height != lastKnownContentHeight {
            lastKnownContentHeight = textView.intrinsicContentSize.height

            // Send a `multilineTextInputHeightDidChange` message through the
            // UIView Responder Chain. The collection superview, if having
            // conforming to `MultilineTextInputAware`, should fire a new layout
            // pass taking account of the new content height upon reception.
            UIApplication.shared.sendAction(
                #selector(MultilineTextInputAware.multilineTextInputHeightDidChange),
                to: nil,
                from: self,
                for: nil
            )
        }
    }

    public func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        textView.inputAccessoryView = FocusToolbar(view: self)
        return true
    }

    public func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        return true
    }
}

extension Component.MultilineTextInput {
    public final class StyleSheet: BaseViewStyleSheet<View> {
        public var font: UIFont
        public var textColor: UIColor
        public var placeholderTextColor: UIColor

        public init(font: UIFont, textColor: UIColor, placeholderTextColor: UIColor) {
            self.font = font
            self.textColor = textColor
            self.placeholderTextColor = placeholderTextColor
            super.init()
        }

        public override func apply(to view: View) {
            view.textView.font = font
            view.placeholderLabel.font = font
            view.textView.textColor = textColor
            view.placeholderLabel.textColor = placeholderTextColor
            super.apply(to: view)
        }
    }
}
