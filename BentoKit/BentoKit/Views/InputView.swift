import UIKit
import Bento
import StyleSheets

final class InputView: UIView {
    private var state: (AnyBox, UITableView)?

    override var intrinsicContentSize: CGSize {
        if let (box, _) = state {
            let width = UIScreen.main.bounds.width
            return CGSize(width: width, height: box.tableViewHeightBoundTo(width: bounds.size.width, inheritedMargins: .zero))
        } else {
            return .zero
        }
    }

    init() {
        super.init(frame: .zero)
        autoresizingMask = []
        translatesAutoresizingMaskIntoConstraints = false
    }

    func update(_ input: CustomInput) {
        let box = input.makeCustomInputBox()

        if let (currentBox, tableView) = state, currentBox.type == box.type {
            box.unsafeRender(in: tableView, animated: false)
        } else {
            state?.1.removeFromSuperview()

            let tableView = UITableView(frame: .zero, style: .plain)
            tableView.isScrollEnabled = false
            tableView.separatorStyle = .none
            tableView.rowHeight = UITableView.automaticDimension
            tableView.estimatedRowHeight = 64
            tableView.sectionHeaderHeight = UITableView.automaticDimension
            tableView.estimatedSectionHeaderHeight = 64
            tableView.sectionFooterHeight = UITableView.automaticDimension
            tableView.estimatedSectionFooterHeight = 64

            tableView.add(to: self).pinEdges(to: self)
            box.unsafeRender(in: tableView, animated: false)

            state = (box, tableView)
        }

        invalidateIntrinsicContentSize()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
