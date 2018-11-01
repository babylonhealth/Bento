import Foundation
import UIKit

/// Inspired (pretty much copied 😛) by https://github.com/devxoul/Then
protocol With {}

extension With where Self: Any {

    /// Makes it available to set properties with closures just after initializing and copying the value types.
    ///
    ///     let label = UILabel().with {
    ///       $0.textAlignment = .center
    ///       $0.textColor = .black
    ///       $0.text = "Hello, World!"
    ///     }
    ///
    ///     let frame = CGRect().with {
    ///       $0.origin.x = 10
    ///       $0.size.width = 100
    ///     }
    @discardableResult func with(_ block: (inout Self) throws -> Void) rethrows -> Self {
        var copy = self
        try block(&copy)
        return copy
    }
}

extension NSObject: With {}
extension UIEdgeInsets: With {}
