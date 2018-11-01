import UIKit

extension UICollectionView {
    public func prepareForBoxRendering<SectionID: Hashable, ItemID: Hashable>(
        sectionIdType: SectionID.Type,
        rowIdType: ItemID.Type
    ) {
        prepareForBoxRendering(with: BentoCollectionViewAdapter<SectionID, ItemID>(with: self))
    }

    public func prepareForBoxRendering<SectionID, ItemID>(
        with adapter: CollectionViewAdapter<SectionID, ItemID>
    ) {
        precondition(typeErasedAdapter == nil, "Preparation must happen before any Bento `Box` rendering occurrence.")
        precondition(adapter.collectionView == self, "The custom adapter is not created for the collection view it is deployed to.")

        self.delegate = adapter
        self.dataSource = adapter
        reloadData()
        layoutIfNeeded()
        objc_setAssociatedObject(self, AssociatedKey.adapter, adapter, .OBJC_ASSOCIATION_RETAIN)
    }

    public func render<SectionID, ItemID>(_ box: Box<SectionID, ItemID>) {
        render(box, animated: true)
    }

    public func render<SectionID, ItemID>(_ box: Box<SectionID, ItemID>, animated: Bool = true, completion: (() -> Void)? = nil) {
        let adapter: CollectionViewAdapterBase<SectionID, ItemID> = getAdapter()
        adapter.update(sections: box.sections, animated: animated, completion: completion)
        didRenderBox()
    }

    private struct AssociatedKey {
        static let adapter = UnsafeMutablePointer<CChar>.allocate(capacity: 1)
    }

    func getAdapter<SectionID, ItemID>() -> CollectionViewAdapterBase<SectionID, ItemID> {
        if let adapter = typeErasedAdapter {
            precondition(adapter is CollectionViewAdapterBase<SectionID, ItemID>,
                         "Adapter type `\(type(of: adapter))` does not match the expected section and/or row ID type: \(SectionID.self) and \(ItemID.self).")
            return unsafeDowncast(adapter, to: CollectionViewAdapterBase<SectionID, ItemID>.self)
        }

        prepareForBoxRendering(sectionIdType: SectionID.self, rowIdType: ItemID.self)
        return getAdapter()
    }

    var typeErasedAdapter: AnyObject? {
        return objc_getAssociatedObject(self, AssociatedKey.adapter) as AnyObject?
    }
}
