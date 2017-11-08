import ReactiveSwift
import Result
import BabylonFoundation

public protocol Form {
    associatedtype Identifier: Hashable

    var components: Property<[FormItem<Identifier>]> { get }
    var isSubmitting: Property<Bool> { get }
}
