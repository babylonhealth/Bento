import ReactiveSwift
import Result
import BabylonFoundation

public protocol Form {
    var components: Property<[FormComponent]> { get }
    var isSubmitting: Property<Bool> { get }
}

public protocol RefreshableForm: Form {
    var refresh: ActionInput<Void> { get }
}
