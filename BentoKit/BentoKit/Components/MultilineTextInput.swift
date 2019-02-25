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
            showsSendButton: Bool = false,
            didChangeText: Optional<(String) -> Void> = nil,
            didFinishEditing: @escaping (String) -> Void,
            styleSheet: StyleSheet
        ) {
            self.configurator = { view in
                view.textView.text = text
                view.placeholderLabel.text = placeholder
                view.placeholderLabel.isHidden = text.isEmpty == false
                view.didFinishEditing = didFinishEditing
                view.didChangeText = didChangeText
                view.sendButton.isEnabled = text.isEmpty.isFalse
                view.sendButton.isHidden = showsSendButton.isFalse
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

        fileprivate let placeholderLabel = UILabel().with {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        fileprivate let contentView = UIView()
        fileprivate let sendButton = UIButton(type: .system).with {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.setContentHuggingPriority(.required, for: .vertical)
            $0.setContentHuggingPriority(.required, for: .horizontal)
            $0.setContentCompressionResistancePriority(.required, for: .horizontal)
            $0.setContentCompressionResistancePriority(.required, for: .vertical)
            $0.widthAnchor.constraint(greaterThanOrEqualToConstant: 30).activated()
            $0.heightAnchor.constraint(greaterThanOrEqualToConstant: 30).activated()
        }

        var didFinishEditing: Optional<(String) -> Void> = nil
        var didChangeText: Optional<(String) -> Void> = nil

        private var lastKnownContentHeight: CGFloat = 0.0

        public override init(frame: CGRect) {
            super.init(frame: frame)

            textView.delegate = self
            sendButton.addTarget(
                self,
                action: #selector(sendButtonPressed),
                for: .primaryActionTriggered
            )

            contentView.add(to: self).pinEdges(to: layoutMarginsGuide)

            stack(.horizontal, spacing: 4, alignment: .bottom)(
                textView,
                sendButton
            )
            .add(to: contentView)
            .pinEdges(to: contentView.layoutMarginsGuide)


            contentView.addSubview(placeholderLabel)

            // Pin the placeholder label to the layout margins guide. The bottom
            // edge should have lower priority than 1000 so that the UITextView
            // can take precedence when the content height is being determined.
            NSLayoutConstraint.activate([
                contentView.layoutMarginsGuide.topAnchor.constraint(equalTo: placeholderLabel.topAnchor),
                contentView.layoutMarginsGuide.leadingAnchor.constraint(equalTo: placeholderLabel.leadingAnchor),
                contentView.layoutMarginsGuide.trailingAnchor.constraint(equalTo: placeholderLabel.trailingAnchor),
                contentView.layoutMarginsGuide.bottomAnchor.constraint(equalTo: placeholderLabel.bottomAnchor)
                    .withPriority(.defaultHigh),
            ])
        }

        @available(*, unavailable)
        public required init?(coder aDecoder: NSCoder) { fatalError() }

        @objc
        private func sendButtonPressed() {
            guard let text = textView.text, text.isEmpty.isFalse else { return }
            textView.resignFirstResponder()
            didFinishEditing?(text)
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
        sendButton.isEnabled = textView.text.isEmpty.isFalse

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
        textView.inputAccessoryView = sendButton.isHidden ? FocusToolbar(view: self) : nil
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
        public var content: ViewStyleSheet<UIView>
        public var send: ButtonStyleSheet

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
            text: TextStyleSheet<UITextView> = TextStyleSheet(),
            content: ViewStyleSheet<UIView> = ViewStyleSheet(layoutMargins: .zero),
            send: ButtonStyleSheet = ButtonStyleSheet().compose(\.layoutMargins, .zero)
        ) {
            self.placeholderTextColor = placeholderTextColor
            self.textContainerInset = textContainerInset
            self.text = text
            self.content = content
            self.send = send
        }

        public override func apply(to view: View) {
            view.placeholderLabel.font = text.font
            view.placeholderLabel.textColor = placeholderTextColor
            view.textView.textContainerInset = textContainerInset
            text.apply(to: view.textView)
            content.apply(to: view.contentView)
            send.apply(to: view.sendButton)
            super.apply(to: view)
        }
    }
}
