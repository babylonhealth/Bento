import UIKit

public final class DescriptionCellViewModel {
    public let text: String
    public let type: DescriptionCellType
    public let visualDependencies: VisualDependenciesProtocol
    public let selectionStyle: UITableViewCellSelectionStyle
    public let backgroundColorStyle: UIViewStyle<UIView>

    public init(text: String, type: DescriptionCellType, visualDependencies: VisualDependenciesProtocol, selectionStyle: UITableViewCellSelectionStyle = .none, backgroundColorStyle: UIViewStyle<UIView>? = nil) {

        self.text = text
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
        case let .custom(labelStyle):
            labelStyle.apply(to: label)
        }
    }

    public func applyText(to label: UILabel) {
        label.text = self.text
    }

    public func applyBackgroundColor(to views: [UIView]) {
        self.backgroundColorStyle.apply(to: views)
    }
}
