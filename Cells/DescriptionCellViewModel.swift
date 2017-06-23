import UIKit

public struct DescriptionCellViewModel {
    public let text: String
    public let type: DescriptionCellType
    public let visualDependencies: VisualDependenciesProtocol
    public let selectionStyle: UITableViewCellSelectionStyle

    public init(text: String, type: DescriptionCellType, visualDependencies: VisualDependenciesProtocol, selectionStyle: UITableViewCellSelectionStyle = .none) {

        self.text = text
        self.type = type
        self.visualDependencies = visualDependencies
        self.selectionStyle = selectionStyle
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
        }
    }

    public func applyText(to label: UILabel) {
        label.text = self.text
    }

    public func applyBackgroundColor(to views: [UIView]) {
        self.visualDependencies.styles.backgroundTransparentColor.apply(to: views)
    }
}
