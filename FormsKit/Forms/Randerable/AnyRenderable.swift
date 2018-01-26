import UIKit

final class AnyRenderable {
    private let reuseIdentifier: String
    private let generator: () -> UIView
    private let render: (UIView) -> Void

    init<R: Renderable>(renderable: R) {
        self.reuseIdentifier = renderable.reuseIdentifier
        self.generator = {
            switch renderable.strategy {
            case .`class`: return R.View()
            case .nib: return R.View.loadFromNib()
            }
        }
        self.render = { (view) in renderable.render(in: (view as! R.View)) }
    }

    func renderCell(in tableView: UITableView, for indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as? TableViewCell else {
            tableView.register(TableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
            return renderCell(in: tableView, for: indexPath)
        }
        let componentView: UIView
        if let containedView = cell.containedView {
            componentView = containedView
        } else {
            componentView = generator()
            cell.install(view: componentView)
        }
        render(componentView)
        return cell
    }

    func renderHeaderFooter(in tableView: UITableView, for section: Int) -> UITableViewHeaderFooterView {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: reuseIdentifier) as? TableViewHeaderFooterView else {
            tableView.register(TableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: reuseIdentifier)
            return renderHeaderFooter(in: tableView, for: section)
        }
        let componentView: UIView
        if let containedView = header.containedView {
            componentView = containedView
        } else {
            componentView = generator()
            header.install(view: componentView)
        }
        render(componentView)
        return header
    }
}
