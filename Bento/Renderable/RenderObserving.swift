extension Renderable where View: UIView {
    public func on<View>(didRender: @escaping (View) -> Void) -> AnyRenderable where View == Self.View {
        return RenderObservingComponent(base: self, didRender: didRender)
            .asAnyRenderable()
    }
}

protocol RenderObserving {
    func didRender(view: UIView)
}

final class RenderObservingComponent<Base: Renderable, View: UIView>: AnyRenderableBox<Base>, RenderObserving where Base.View == View {
    private let source: AnyRenderableBox<Base>
    private let didRender: (View) -> Void

    init(base: Base, didRender: @escaping (View) -> Void) {
        source = AnyRenderableBox(base)
        self.didRender = didRender
        super.init(base)
    }

    func didRender(view: UIView) {
        guard let _view = view as? View else {
            assertionFailure("Couldn't cast \(view) to \(View.self)")
            return
        }
        didRender(_view)
    }

    override func cast<T>(to type: T.Type) -> T? {
        if type == RenderObserving.self {
            return self as? T
        }
        return source.cast(to: type)
    }
}
