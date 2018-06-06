import UIKit

final class CollectionViewSupplementaryView: UICollectionReusableView {
    var containedView: UIView? = nil

    func install(view: UIView) {
        containedView = view
        addSubview(view)
        view.pinToEdges(of: self)
    }
}
