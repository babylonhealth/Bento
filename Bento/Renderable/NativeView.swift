import UIKit

public typealias NativeView = UIView

extension NativeView {
    @nonobjc public static func generate() -> UIView {
        if let viewType = self as? (UIView & NibLoadable).Type {
            return viewType.loadFromNib()
        }

        return self.init()
    }
}
