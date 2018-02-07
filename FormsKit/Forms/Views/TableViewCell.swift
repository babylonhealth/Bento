import UIKit

final class TableViewCell: UITableViewCell {

    var containedView: UIView? = nil

    func install(view: UIView) {
        self.containedView = view
        contentView.addSubview(view)
        view.pinToEdges(of: contentView)
    }
}
