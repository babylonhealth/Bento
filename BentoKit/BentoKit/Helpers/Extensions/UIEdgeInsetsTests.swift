import UIKit

extension UIEdgeInsets {
    public var horizontal: UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: left, bottom: 0, right: right)
    }

    public var verticalTotal: CGFloat {
        return top + bottom
    }

    public var horizontalTotal: CGFloat {
        return left + right
    }
}
