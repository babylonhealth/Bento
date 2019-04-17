import UIKit

extension NSLayoutConstraint {
    func withPriority(_ priority: UILayoutPriority) -> NSLayoutConstraint {
        self.priority = priority
        return self
    }

    @discardableResult
    func activated() -> NSLayoutConstraint {
        self.isActive = true
        return self
    }
}

extension UILayoutPriority {
    static var cellRequired: UILayoutPriority {
        return .required - 1.0
    }

    static func - (priority: UILayoutPriority, value: Float) -> UILayoutPriority {
        return UILayoutPriority(rawValue: priority.rawValue - value)
    }
}
