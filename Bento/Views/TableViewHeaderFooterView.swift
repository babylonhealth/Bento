import UIKit

final class TableViewHeaderFooterView: UITableViewHeaderFooterView {
    var containedView: UIView? = nil

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
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
