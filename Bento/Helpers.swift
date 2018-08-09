import UIKit

public protocol NibLoadable {
    static var nib: UINib { get }
}

public extension NibLoadable where Self: UIView {
    static var nib: UINib {
        return UINib(nibName: String(describing: self), bundle: Bundle(for: self))
    }

    static func loadFromNib() -> Self {
        return nib.instantiate(withOwner: nil, options: nil).first as! Self
    }
}

extension UIView {
    func pinToEdges(of view: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: topAnchor),
            view.leftAnchor.constraint(equalTo: leftAnchor),
            view.bottomAnchor.constraint(equalTo: bottomAnchor),
            view.rightAnchor.constraint(equalTo: rightAnchor)
        ])
    }
}

extension UICollectionView {
    private struct AssociatedKey {
        static let key = UnsafeMutablePointer<CChar>.allocate(capacity: 1)
    }

    func getAdapter<SectionId, ItemId>() -> CollectionViewDataSource<SectionId, ItemId> {
        guard let adapter = objc_getAssociatedObject(self, AssociatedKey.key) as? CollectionViewDataSource<SectionId, ItemId> else {
            let adapter = CollectionViewDataSource<SectionId, ItemId>(with: self)
            objc_setAssociatedObject(self, AssociatedKey.key, adapter, .OBJC_ASSOCIATION_RETAIN)
            return getAdapter()
        }
        return adapter
    }
}

extension Optional {
    func zip<T, R>(with other: T?, _ selector: (Wrapped, T) -> R) -> Optional<R> {
        guard let unwrapped = self, let other = other else {
            return nil
        }
        return selector(unwrapped, other)
    }
}
