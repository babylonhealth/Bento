import UIKit

public typealias NativeView = UIView

extension NativeView {
    @nonobjc static func generate() -> UIView {
        if let viewType = self as? (UIView & NibLoadable).Type {
            return viewType.loadFromNib()
        }

        return self.init()
    }

    @nonobjc static var typeName: String {
        return String(describing: self)
    }
}
