/// Provide generic parameter agnostic access to the adapter.
internal protocol AdapterStoreAccessible: AnyObject {
    var layoutMargins: UIEdgeInsets { get set }
    var boundSize: CGSize { get set }
    var cachesSizeInformation: Bool { get set }
}

/// Provide a default implementation for all adapter store owners.
internal protocol AdapterStoreOwner: AdapterStoreAccessible {
    associatedtype SectionID: Hashable
    associatedtype ItemID: Hashable

    var store: AdapterStore<SectionID, ItemID> { get set }
}

extension AdapterStoreOwner {
    var layoutMargins: UIEdgeInsets {
        get { return store.layoutMargins }
        set { store.layoutMargins = newValue }
    }

    var boundSize: CGSize {
        get { return store.boundSize }
        set { store.boundSize = newValue }
    }

    var cachesSizeInformation: Bool {
        get { return store.cachesSizeInformation }
        set { store.cachesSizeInformation = newValue }
    }
}
