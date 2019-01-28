import UIKit

extension Renderable where View: UIView {
    public func deletable(
        deleteActionText: String,
        backgroundColor: UIColor? = nil,
        didDelete: @escaping () -> Void
    ) -> AnyRenderable {
        return DeletableComponent(
            source: self,
            deleteActionText: deleteActionText,
            backgroundColor: backgroundColor,
            didDelete: didDelete
        ).asAnyRenderable()
    }
}

protocol Deletable {
    var deleteActionText: String { get }
    var backgroundColor: UIColor? { get }

    func delete()
}

final class DeletableComponent<Base: Renderable>: AnyRenderableBox<Base>, Deletable where Base.View: UIView {
    let deleteActionText: String
    let backgroundColor: UIColor?
    private let source: AnyRenderableBox<Base>
    private let didDelete: () -> Void

    init(
        source: Base,
        deleteActionText: String,
        backgroundColor: UIColor?,
        didDelete: @escaping () -> Void
    ) {
        self.deleteActionText = deleteActionText
        self.backgroundColor = backgroundColor
        self.source = AnyRenderableBox<Base>(source)
        self.didDelete = didDelete
        super.init(source)
    }

    override func cast<T>(to type: T.Type) -> T? {
        if type == Deletable.self {
            return self as? T
        }
        return source.cast(to: type)
    }

    func delete() {
        didDelete()
    }
}
