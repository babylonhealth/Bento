import UIKit
import ReactiveSwift
import ReactiveCocoa
import Result

public protocol SelectionGroup: class {
    /// The unique identifier of the current selection in the group.
    var selection: Property<Int?> { get }

    /// Whether the group is processing a user selection or a detail disclosure request.
    var isExecuting: Property<Bool> { get }

    /// Process a user selection of the given unique identifier.
    var userSelected: (Int) -> SignalProducer<Never, NoError> { get }

    /// Request details for the selection item of the given unique identifier.
    ///
    /// The default implementation is `nil`. If any action is provided, `SelectionCell`
    /// would display a detail disclosure button with an alternative layout.
    var discloseDetails: ((Int) -> SignalProducer<Never, NoError>)? { get }
}

extension SelectionGroup {
    public var discloseDetails: ((Int) -> SignalProducer<Never, NoError>)? {
        return nil
    }
}
