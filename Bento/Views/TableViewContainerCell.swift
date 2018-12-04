import UIKit

final class TableViewContainerCell: UITableViewCell {
    var containedView: UIView? {
        didSet {
            containerViewDidChange(from: oldValue, to: containedView)
        }
    }

    var component: AnyRenderable?

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        selectionStyle = .none
    }

    override func responds(to aSelector: Selector!) -> Bool {
        guard let component = component?.cast(to: MenuItemsResponding.self) else {
            return super.responds(to: aSelector)
        }

        return component.responds(to: aSelector) || super.responds(to: aSelector)
    }

    override func forwardingTarget(for aSelector: Selector!) -> Any? {
        guard let component = component?.cast(to: MenuItemsResponding.self) else {
            return super.forwardingTarget(for: aSelector)
        }

        return component
    }

    // NOTE: Self sizing overriding point.
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return containedView?.sizeThatFits(size) ?? super.sizeThatFits(size)
    }
}

extension TableViewContainerCell: BentoReusableView {}
