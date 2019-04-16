import UIKit

public protocol HeightCustomizing {
    func height(forWidth width: CGFloat, inheritedMargins: UIEdgeInsets) -> CGFloat
    func estimatedHeight(forWidth width: CGFloat, inheritedMargins: UIEdgeInsets) -> CGFloat
}
