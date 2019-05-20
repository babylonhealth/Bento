import UIKit

final class CollectionViewContainerReusableView: UICollectionReusableView {
    var containedView: UIView? {
        didSet {
            containerViewDidChange(from: oldValue, to: containedView)
        }
    }

    var contentView: UIView {
        return self
    }

    var component: AnyRenderable?
    var storage: [StorageKey : Any] = [:]

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        bind(nil)
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

    override func prepareForReuse() {
        super.prepareForReuse()

        bind(nil)
    }
}

extension CollectionViewContainerReusableView: BentoReusableView {}
