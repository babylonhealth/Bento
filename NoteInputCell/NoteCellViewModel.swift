import ReactiveSwift
import Result
import UIKit

/// Display a multi-line, read-only note.
///
/// - note: It is backed by `NoteInputCell`, but with user interaction disabled.
public final class NoteCellViewModel: FocusableFormComponent {
    let placeholder: String?
    let text: Property<String>
    private let originalRichText: NSAttributedString?
    let visualDependencies: VisualDependenciesProtocol

    var richText: NSAttributedString? {
        return originalRichText.map { text in
            // `NSAttributedString` overrides the style. 🤷‍♂️
            let string = NSMutableAttributedString(attributedString: text)
            string.setAttributes([.font: UIFont.preferredFont(forTextStyle: .body)],
                                 range: NSRange(location: 0, length: string.length))
            return string
        }
    }

    public init(placeholder: String?, text: Property<String>, richText: NSAttributedString?, visualDependencies: VisualDependenciesProtocol) {
        self.placeholder = placeholder
        self.text = text
        self.originalRichText = richText
        self.visualDependencies = visualDependencies
    }

    func applyStyle(to label: UILabel) {
        visualDependencies.styles.customPlaceholder.apply(to: label)
    }

    func applyStyle(to textView: UITextView) {
        visualDependencies.styles.textViewForm.apply(to: textView)
        visualDependencies.styles.tintBrandColor.apply(to: textView)
        textView.autocapitalizationType = autocapitalizationType
        textView.autocorrectionType = autocorrectionType
        textView.keyboardType = keyboardType
    }

    func applyStyle(to button: UIButton) {
        button.setImage(visualDependencies.styles.formIcons.cameraImage, for: .normal)
    }

    func applyBackgroundColor(to views: [UIView]) {
        visualDependencies.styles.backgroundCustomColor.apply(color: visualDependencies.styles.appColors.formTextFieldTextBackgroundColor, to: views)
    }
}
