import ReactiveSwift

public protocol Form {
    var components: Property<[FormComponent]> { get }
    var isSubmitting: Property<Bool> { get }
}
