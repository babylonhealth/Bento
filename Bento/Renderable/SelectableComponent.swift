protocol Selectable {
    var selectionColor: UIColor? { get }
    
    func select()
}

class SelectableComponent<Base: Renderable>: AnyRenderableBox<Base>, Selectable where Base.View: UIView {
    private let source: AnyRenderableBox<Base>
    private let didSelect: () -> Void
    let selectionColor: UIColor?
    
    init(base: Base, selectionColor: UIColor?, didSelect: @escaping () -> Void) {
        self.source = AnyRenderableBox(base)
        self.didSelect = didSelect
        self.selectionColor = selectionColor
        super.init(base)
    }
    
    func select() {
        didSelect()
    }
    
    override func cast<T>(to type: T.Type) -> T? {
        if type == Selectable.self {
            return self as? T
        }
        return source.cast(to: type)
    }
}
