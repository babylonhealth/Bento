/// Represent a component that can be focused (assume first responder) and
/// participates in Bento focus coordination.
///
/// - important: Your component root view should conform to `FocusableView`.
public protocol Focusable {
    /// Declare whether the component is eligible for focus.
    var focusEligibility: FocusEligibility { get }
}

public enum FocusEligibility: Equatable {
    /// The component is not eligible for focus.
    ///
    /// For example, the component is focusable but is currently disabled.
    case ineligible

    /// The component is eligible for focus.
    ///
    /// The focus search utilizes the specified content status to filter out
    /// components, should the user request to skip over components already
    /// populated with content.
    case eligible(ContentStatus)

    public enum ContentStatus: Equatable {
        /// The component has been populated with content.
        case populated

        /// The component does not have any content.
        case empty

        public static var `default`: ContentStatus {
            return .empty
        }
    }

    internal func isEligible(skipsPopulatedComponents: Bool) -> Bool {
        switch self {
        case .ineligible:
            return false
        case .eligible(.populated):
            return !skipsPopulatedComponents
        case .eligible(.empty):
            return true
        }
    }
}
