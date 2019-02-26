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
        /// NOTE: `String.init(reflecting:)` gives the fully qualified type name.
        //        Metatype address is appended to make this agnostic of any change in type name printing.
        return "\(String(reflecting: self)):\(UInt(bitPattern: ObjectIdentifier(self)))"
    }
}
