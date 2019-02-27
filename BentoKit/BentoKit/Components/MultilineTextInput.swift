import Bento
import StyleSheets

@objc public protocol MultilineTextInputAware where Self: UIView {
    func multilineTextInputHeightDidChange(_ sender: Any)
}

extension Component {
    public final class MultilineTextInput: AutoRenderable, Focusable {
        public let configurator: (View) -> Void
        public let focusEligibility: FocusEligibility
        public let styleSheet: Component.MultilineTextInput.StyleSheet

        public init(
            text: String,
            placeholder: String,
            showsFocusToolbar: Bool = true,
            didChangeText: Optional<(String) -> Void> = nil,
            didFinishEditing: @escaping (String) -> Void,
            styleSheet: StyleSheet
        ) {
            self.configurator = { view in
                view.showsFocusToolbar = showsFocusToolbar
                view.textView.text = text
                view.placeholderLabel.text = placeholder
                view.placeholderLabel.isHidden = text.isEmpty == false
                view.didFinishEditing = didFinishEditing
                view.didChangeText = didChangeText
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
            $0.setContentCompressionResistancePriority(.cellRequired, for: .vertical)
            $0.textContainerInset = .zero
            $0.textContainer.lineFragmentPadding = 0.0
        }

        fileprivate var textContainerInset = UIEdgeInsets.zero {
            didSet {
                textView.textContainerInset = textContainerInset
                placeHolderConstraints.forEach { $0.isActive = false }

                // Pin the placeholder label to the contentView. The bottom
                // edge should have lower priority than 1000 so that the UITextView
                // can take precedence when the content height is being determined.
                placeHolderConstraints = [
                    layoutMarginsGuide.topAnchor.constraint(equalTo: placeholderLabel.topAnchor, constant: textContainerInset.top),
                    layoutMarginsGuide.leadingAnchor.constraint(equalTo: placeholderLabel.leadingAnchor, constant: textContainerInset.left),
                    layoutMarginsGuide.trailingAnchor.constraint(equalTo: placeholderLabel.trailingAnchor, constant: textContainerInset.right),
                    layoutMarginsGuide.bottomAnchor.constraint(equalTo: placeholderLabel.bottomAnchor, constant: textContainerInset.bottom)
                        .withPriority(.defaultHigh),
                ]

                placeHolderConstraints.forEach { $0.isActive = true }
            }
        }

        fileprivate var showsFocusToolbar = true

        fileprivate let placeholderLabel = UILabel().with {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        fileprivate var didFinishEditing: Optional<(String) -> Void> = nil
        fileprivate var didChangeText: Optional<(String) -> Void> = nil

        private var lastKnownContentHeight: CGFloat = 0.0
        private var placeHolderConstraints = [NSLayoutConstraint]()

        public override init(frame: CGRect) {
            super.init(frame: frame)

            textView.delegate = self

            textView.add(to: self).pinEdges(to: layoutMarginsGuide)
            addSubview(placeholderLabel)
        }

        @available(*, unavailable)
        public required init?(coder aDecoder: NSCoder) { fatalError() }

        public override func resignFirstResponder() -> Bool {
            textView.resignFirstResponder()
            return super.resignFirstResponder()
        }
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
        didChangeText?(textView.text)
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
        textView.inputAccessoryView = showsFocusToolbar ? FocusToolbar(view: self) : nil
        return true
    }

    public func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        return true
    }
}

extension Component.MultilineTextInput {
    public final class StyleSheet: BaseViewStyleSheet<View> {
        public var placeholderTextColor: UIColor
        public var textContainerInset: UIEdgeInsets
        public var text: TextStyleSheet<UITextView>

        public convenience init(
            font: UIFont,
            textColor: UIColor,
            placeholderTextColor: UIColor
        ) {
            self.init(
                placeholderTextColor: placeholderTextColor,
                text: TextStyleSheet(font: font, textColor: textColor)
            )
        }

        public init(
            placeholderTextColor: UIColor,
            textContainerInset: UIEdgeInsets = .zero,
            text: TextStyleSheet<UITextView> = TextStyleSheet()
        ) {
            self.placeholderTextColor = placeholderTextColor
            self.textContainerInset = textContainerInset
            self.text = text
        }

        public override func apply(to view: View) {
            view.placeholderLabel.font = text.font
            view.placeholderLabel.textColor = placeholderTextColor
            view.textContainerInset = textContainerInset
            text.apply(to: view.textView)
            super.apply(to: view)
        }
    }
}
