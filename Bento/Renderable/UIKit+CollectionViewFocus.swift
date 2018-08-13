import UIKit

extension UITableView {
    public func focus(direction: FocusSearchDirection = .backward, skipsPopulatedComponents: Bool = true, animated: Bool = true) {
        focusItem(nextTo: nil,
                  direction: direction,
                  skipsPopulatedComponents: skipsPopulatedComponents,
                  animated: animated)
    }
}

extension UICollectionView {
    public func focus(direction: FocusSearchDirection = .backward, skipsPopulatedComponents: Bool = true, animated: Bool = true) {
        focusItem(nextTo: nil,
                  direction: direction,
                  skipsPopulatedComponents: skipsPopulatedComponents,
                  animated: animated)
    }
}
