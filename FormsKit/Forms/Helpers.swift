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
