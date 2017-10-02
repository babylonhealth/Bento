import UIKit
import ReactiveSwift
import Result

public final class DescriptionCellViewModel {
    public let text: String
    public let selected: Action<Void, Void, NoError>?
    public let type: DescriptionCellType
    public let visualDependencies: VisualDependenciesProtocol
    public let selectionStyle: UITableViewCellSelectionStyle
    public let backgroundColorStyle: UIViewStyle<UIView>

    public init(text: String,
                type: DescriptionCellType,
                visualDependencies: VisualDependenciesProtocol,
                selectionStyle: UITableViewCellSelectionStyle = .none,
                backgroundColorStyle: UIViewStyle<UIView>? = nil,
                selected: Action<Void, Void, NoError>? = nil) {
        self.text = text
        self.selected = selected
        self.type = type
        self.visualDependencies = visualDependencies
        self.selectionStyle = selectionStyle
        self.backgroundColorStyle = backgroundColorStyle ?? visualDependencies.styles.backgroundTransparentColor
    }

    public func applyStyle(to label: UILabel) {
        switch type {
        case .header:
            visualDependencies.styles.labelFormHeader.apply(to: label)
        case .headline:
            visualDependencies.styles.labelFormHeadline.apply(to: label)
        case .link:
            visualDependencies.styles.labelFormLink.apply(to: label)
        case .footer:
            visualDependencies.styles.labelFormFooter.apply(to: label)
        case .alert:
            visualDependencies.styles.labelFormAlert.apply(to: label)
        case .captionText:
            visualDependencies.styles.labelFormCaption.apply(to: label)
        case .centeredTitle, .centeredTitleWithDisclosureIndicator:
            visualDependencies.styles.labelFormCenterTitleValue.apply(to: label)
        case .centeredSubtitle:
            visualDependencies.styles.labelFormCenterSubtitleValue.apply(to: label)
        case let .custom(labelStyle):
            labelStyle.apply(to: label)
        }
    }

    public func applyText(to label: UILabel) {
        if case .centeredTitleWithDisclosureIndicator = type {
            let attachment = NSTextAttachment()
            attachment.image = visualDependencies.styles.disclosureIndicator

            let text = NSMutableAttributedString(string: self.text)
            text.append(NSAttributedString(string: " "))
            text.append(NSAttributedString(attachment: attachment))

            label.attributedText = text
        } else {
            label.text = text
        }
    }

    public func applyBackgroundColor(to views: [UIView]) {
        self.backgroundColorStyle.apply(to: views)
    }
}
