import UIKit

public enum Device {
    case iPhone6
    case iPhone6Plus
    case iPhoneX

    public static var all: [Device] {
        return [iPhone6, iPhone6Plus, iPhoneX]
    }

    public var size: CGSize {
        switch self {
        case .iPhone6:
            return CGSize(width: 375, height: 667)
        case .iPhone6Plus:
            return CGSize(width: 414, height: 736)
        case .iPhoneX:
            return CGSize(width: 375, height: 812)
        }
    }

    public var indentifier: String {
        switch self {
        case .iPhone6:
            return "iPhone6"
        case .iPhone6Plus:
            return "iPhone6Plus"
        case .iPhoneX:
            return "iPhoneX"
        }
    }

    var traits: UITraitCollection {
        return UITraitCollection(traitsFrom: [
            UITraitCollection(userInterfaceIdiom: .phone),
            UITraitCollection(verticalSizeClass: .regular),
            UITraitCollection(horizontalSizeClass: .compact),
        ])
    }
}
