import ReactiveSwift
import Result

public protocol Form {
    var components: Property<[FormComponent]> { get }
    var isSubmitting: Property<Bool> { get }
}

public protocol RefreshableForm: Form {
    var refresh: Action<Void, Never, NoError> { get }
}
