import UIKit

extension UIEdgeInsets {
    var horizontal: UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: left, bottom: 0, right: right)
    }

    var verticalTotal: CGFloat {
        return top + bottom
    }

    var horizontalTotal: CGFloat {
        return left + right
    }
}
