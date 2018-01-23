
func abstractMethod() -> Never {
    fatalError("Abstract Method")
}

public protocol NibLodable {
    static var nib: UINib { get }
}

public extension NibLodable where Self: UIView {
    static var nib: UINib {
        return UINib(nibName: String(describing: self), bundle: Bundle(for: self))
    }

    static func loadFromNib() -> Self {
        return nib.instantiate(withOwner: nil, options: nil).first as! Self
    }
}
extension UIView: NibLodable {}
