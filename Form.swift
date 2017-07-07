import ReactiveSwift

public protocol Form {
    var components: Property<[FormComponent]> { get }
    var submiting: Property<Bool> { get }
}
