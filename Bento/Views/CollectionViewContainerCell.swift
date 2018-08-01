import UIKit

final class CollectionViewContainerCell: UICollectionViewCell {
    var containedView: UIView? = nil

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func install(view: UIView) {
        containedView = view
        contentView.addSubview(view)
        view.pinToEdges(of: contentView)
    }
}
