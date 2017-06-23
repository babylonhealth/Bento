import UIKit

public struct EmptySpaceCellViewModel {
    private let visualDependencies: VisualDependenciesProtocol
    let height: Float
    let selectionStyle: UITableViewCellSelectionStyle = .none

    public init(height: Float, visualDependencies: VisualDependenciesProtocol) {
        self.height = height
        self.visualDependencies = visualDependencies
    }

    func applyBackgroundColor(to view: UIView) {
        self.visualDependencies.styles.backgroundTransparentColor.apply(to: view)
    }
}
