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

extension EmptySpaceCellViewModel: Equatable {
    public static func ==(left: EmptySpaceCellViewModel, right: EmptySpaceCellViewModel) -> Bool {
        return left.height == right.height && left.selectionStyle == right.selectionStyle
    }
}
