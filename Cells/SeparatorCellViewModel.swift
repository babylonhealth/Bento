import UIKit

public struct SeparatorCellViewModel {
    let visualDependencies: VisualDependenciesProtocol
    let isFullCell: Bool
    let width: Float
    let selectionStyle: UITableViewCellSelectionStyle = .none

    public init(isFullCell: Bool, visualDependencies: VisualDependenciesProtocol) {
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

extension SeparatorCellViewModel: Equatable {
    public static func ==(left: SeparatorCellViewModel, right: SeparatorCellViewModel) -> Bool {
        return left.isFullCell == right.isFullCell && left.width == right.width && left.selectionStyle == right.selectionStyle
    }
}
