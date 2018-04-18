import UIKit

final class TableViewHeaderFooterView: UITableViewHeaderFooterView {
    var containedView: UIView? = nil

    func install(view: UIView) {
        self.containedView = view
        contentView.addSubview(view)
        view.pinToEdges(of: contentView)
    }
}

final class CollectionViewSupplementaryView: UICollectionReusableView {
    var containedView: UIView? = nil

    func install(view: UIView) {
        self.containedView = view
        self.addSubview(view)
        view.pinToEdges(of: self)
    }
}
