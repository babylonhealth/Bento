import UIKit

open class TableViewStyleSheet: ViewStyleSheet<UITableView> {
    public var rowHeight: CGFloat = UITableView.automaticDimension
    public var sectionHeaderHeight: CGFloat = UITableView.automaticDimension
    public var sectionFooterHeight: CGFloat = UITableView.automaticDimension
    public var isScrollEnabled = true
    public var separatorInset: UIEdgeInsets = .zero
    public var separatorColor: UIColor?

    open override func apply(to element: UITableView) {
        super.apply(to: element)
        element.separatorColor = separatorColor
        element.rowHeight = rowHeight
        element.sectionHeaderHeight = sectionHeaderHeight
        element.sectionFooterHeight = sectionFooterHeight
        element.isScrollEnabled = isScrollEnabled
        element.separatorInset = separatorInset
    }
}
