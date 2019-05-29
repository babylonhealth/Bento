extension Renderable {
    public func styling(_ styleSheet: StyleSheet<View>) -> AnyRenderable {
        return StyledComponent(base: self, styleSheet: styleSheet)
            .asAnyRenderable()
    }
}

struct StyledComponent<Base: Renderable>: Renderable {
    private let styleSheet: StyleSheet<Base.View>
    private let base: Base

    init(
        base: Base,
        styleSheet: StyleSheet<Base.View>
    ) {
        self.styleSheet = styleSheet
        self.base = base
    }

    func render(in view: Base.View) {
        base.render(in: view)
    }

    func didMount(to view: Base.View, storage: ViewStorage) {
        base.didMount(to: view, storage: storage)

        var view = view
        storage[StyledComponent.snapshotForReversion] = styleSheet.apply(to: &view)
    }

    func willUnmount(from view: Base.View, storage: ViewStorage) {
        base.willUnmount(from: view, storage: storage)

        var view = view
        storage[StyledComponent.snapshotForReversion]?.apply(to: &view)
    }

    private static var snapshotForReversion: ViewStorage.Key<StyleSheet<Base.View>> {
        return ViewStorage.Key(StyleSheet<Base.View>.self)
    }
}

