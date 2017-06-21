import UIKit

struct SeparatorCellViewModel {
    let visualDependencies: VisualDependenciesProtocol
    let isFullCell: Bool
    let width: Float
    let selectionStyle: UITableViewCellSelectionStyle = .none

    init(isFullCell: Bool, visualDependencies: VisualDependenciesProtocol) {
        self.isFullCell = isFullCell
        self.visualDependencies = visualDependencies
        self.width = self.isFullCell ? 0 : 16
    }

    func applySeparatorColor(to view: UIView) {
        self.visualDependencies.styles.backgroundCustomColor.apply(color: self.visualDependencies.styles.appColors.formSeparatorColor, to: view)
    }

    func applyBackgroundColor(to view: UIView) {
        self.visualDependencies.styles.backgroundCustomColor.apply(color: Colors.white, to: view)
    }
}
