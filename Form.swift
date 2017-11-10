import ReactiveSwift
import Result
import BabylonFoundation

public enum FormStyle {
    case topYAligned
    case centerYAligned
}

public struct FormTree<ItemIdentifier: Hashable> {
    public let items: [FormItem<ItemIdentifier>]
    public let style: FormStyle

    public init(items: [FormItem<ItemIdentifier>], style: FormStyle = .topYAligned) {
        self.items = items
        self.style = style
    }
}

extension FormTree: ExpressibleByArrayLiteral {
    public init(arrayLiteral: FormItem<ItemIdentifier>...) {
        self.init(items: arrayLiteral)
    }
}

public protocol Form {
    associatedtype Identifier: Hashable

    var tree: Property<FormTree<Identifier>> { get }
    var isSubmitting: Property<Bool> { get }
}
