import UIKit

final class CollectionViewCell: UICollectionViewCell {
    var containedView: UIView? = nil

    func install(view: UIView) {
        containedView = view
        contentView.addSubview(view)
        view.pinToEdges(of: contentView)
    }
}
