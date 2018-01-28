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
extension UIView: NibLoadable {}

extension UIView {
    func pinToEdges(of view: UIView) {
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: topAnchor),
            view.leftAnchor.constraint(equalTo: leftAnchor),
            view.bottomAnchor.constraint(equalTo: bottomAnchor),
            view.rightAnchor.constraint(equalTo: rightAnchor)
        ])
    }
}

extension UITableView {
    private struct AssociatedKey {
        static var key = "FormsKit.UITableView.AssociatedKey.key"
    }
    func getAdapter<SectionId, RowId>() -> SectionedFormAdapter<SectionId, RowId> {
        guard let adapter = objc_getAssociatedObject(self, &AssociatedKey.key) as? SectionedFormAdapter<SectionId, RowId> else {
            let adapter = SectionedFormAdapter<SectionId, RowId>(with: self)
            objc_setAssociatedObject(self, &AssociatedKey.key, adapter, .OBJC_ASSOCIATION_RETAIN)
            return getAdapter()
        }
        return adapter
    }
}
