import UIKit

extension UIView.AnimationOptions {
    init(_ curve: UIView.AnimationCurve) {
        switch curve {
        case .easeIn:
            self = .curveEaseIn
        case .easeOut:
            self = .curveEaseOut
        case .easeInOut:
            self = .curveEaseInOut
        case .linear:
            self = .curveLinear
        // A default case is required here due to UIKeyboard somethings throwing us an undocumented value
        default:
            self = .curveEaseIn
        }
    }
}
