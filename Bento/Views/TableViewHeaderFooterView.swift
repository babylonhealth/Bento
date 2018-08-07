import UIKit

final class TableViewHeaderFooterView: UITableViewHeaderFooterView {
    var containedView: UIView? = nil

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .clear
        preservesSuperviewLayoutMargins = false
        contentView.preservesSuperviewLayoutMargins = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func install(view: UIView) {
        self.containedView = view
        contentView.addSubview(view)
        view.pinToEdges(of: contentView)
    }
}
