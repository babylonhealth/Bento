import UIKit

public enum TextAlignment {
    case center
    case leading
    case trailing
    case justified

    public func systemValue(for layoutDirection: UIUserInterfaceLayoutDirection = .leftToRight) -> NSTextAlignment {
        switch (layoutDirection, self) {
        case (_, .center):
            return .center
        case (.leftToRight, .leading), (.rightToLeft, .trailing):
            return .left
        case (.leftToRight, .trailing), (.rightToLeft, .leading):
            return .right
        case (_, .justified):
            return .justified
        }
    }
}
