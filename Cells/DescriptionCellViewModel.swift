import UIKit

struct DescriptionCellViewModel {
    let text: String
    let type: DescriptionCellType
    let visualDependencies: VisualDependenciesProtocol
    let selectionStyle: UITableViewCellSelectionStyle = .none

    func applyStyle(to label: UILabel) {
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

    func applyText(to label: UILabel) {
        label.text = self.text
    }

    func applyBackgroundColor(to views: [UIView]) {
        self.visualDependencies.styles.backgroundTransparentColor.apply(to: views)
    }
}
