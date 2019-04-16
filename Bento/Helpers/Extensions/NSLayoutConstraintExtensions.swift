import UIKit

extension NSLayoutConstraint {
    public func withPriority(_ priority: UILayoutPriority) -> NSLayoutConstraint {
        self.priority = priority
        return self
    }

    @discardableResult
    public func activated() -> NSLayoutConstraint {
        self.isActive = true
        return self
    }
}

extension UILayoutPriority {
    public static var cellRequired: UILayoutPriority {
        return .required - 1.0
    }

    public static func - (priority: UILayoutPriority, value: Float) -> UILayoutPriority {
        return UILayoutPriority(rawValue: priority.rawValue - value)
    }
}
