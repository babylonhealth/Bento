import Bento
import UIKit

public func renderInTableView<R: Renderable>(
    component: R,
    style: UITableView.Style = .plain,
    size: CGSize = CGSize.iPhoneX
) -> UITableView {
    let box = Box<Int, Int>.empty
        |-+ Section(id: 0)
        |---+ Node(id: 0, component: component)

    let tableView = Bento.BentoTableView(frame: .zero, style: style)
    tableView.frame.size = size
    tableView.prepareForBoxRendering(with: BoxTableViewAdapter<Int, Int>(with: tableView))
    tableView.render(box)

    return tableView
}

public func renderInTableView<ID>(
    nodes: [Node<ID>],
    style: UITableView.Style = .plain,
    size: CGSize = CGSize.iPhoneX
    ) -> UITableView {
    let box = Box<Int, ID>.empty
        |-+ Section(id: 0)
        |---* nodes

    let tableView = BentoTableView(frame: .zero, style: style)
    tableView.frame.size = size
    tableView.prepareForBoxRendering(with: BoxTableViewAdapter<Int, Int>(with: tableView))
    tableView.render(box)

    return tableView
}
