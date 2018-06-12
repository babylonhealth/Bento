import UIKit

final class CollectionViewContainerCell: UICollectionViewCell {
    var containedView: UIView? = nil

    func install(view: UIView) {
        containedView = view
        contentView.addSubview(view)
        view.pinToEdges(of: contentView)
    }
}
