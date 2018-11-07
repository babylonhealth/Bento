import UIKit

final class TableViewHeaderFooterView: UITableViewHeaderFooterView {
    var containedView: UIView? {
        didSet {
            containerViewDidChange(from: oldValue, to: containedView)
        }
    }

    var component: AnyRenderable?

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        let view = UIView()
        view.backgroundColor = .clear
        backgroundView = view
        contentView.backgroundColor = .clear
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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

}

extension TableViewHeaderFooterView: BentoReusableView {}
