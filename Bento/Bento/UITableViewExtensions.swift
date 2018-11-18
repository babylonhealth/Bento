extension UITableView {
    public var animationOptions: TableViewAnimationOptions {
        get {
            let options = objc_getAssociatedObject(self, AssociatedKey.animationOptions) as? TableViewAnimationOptions
            return options ?? TableViewAnimationOptions()
        }
        set {
            objc_setAssociatedObject(self, AssociatedKey.animationOptions, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public func prepareForBoxRendering<SectionID: Hashable, ItemID: Hashable>(
        sectionIdType: SectionID.Type,
        rowIdType: ItemID.Type
    ) {
        prepareForBoxRendering(with: BentoTableViewAdapter<SectionID, ItemID>(with: self))
    }

    public func prepareForBoxRendering<SectionID, ItemID>(
        with adapter: TableViewAdapter<SectionID, ItemID>
    ) {
        precondition(typeErasedAdapter == nil, "Preparation must happen before any Bento `Box` rendering occurrence.")
        precondition(adapter.tableView == self, "The custom adapter is not created for the table view it is deployed to.")

        self.delegate = adapter
        self.dataSource = adapter
        reloadData()
        layoutIfNeeded()
        objc_setAssociatedObject(self, AssociatedKey.adapter, adapter, .OBJC_ASSOCIATION_RETAIN)
    }
    
    public func render<SectionID, ItemID>(_ box: Box<SectionID, ItemID>, animated: Bool = true) {
        let adapter: TableViewAdapterBase<SectionID, ItemID> = getAdapter()
        adapter.update(sections: box.sections, animated: animated, completion: nil)
    }

    @available(iOS 11.0, *)
    public func render<SectionID, ItemID>(_ box: Box<SectionID, ItemID>, animated: Bool = true, completion: ((Bool) -> Void)?) {
        let adapter: TableViewAdapterBase<SectionID, ItemID> = getAdapter()
        adapter.update(sections: box.sections, animated: animated, completion: completion)
    }

    private struct AssociatedKey {
        static let adapter = UnsafeMutablePointer<CChar>.allocate(capacity: 1)
        static let animationOptions = UnsafeMutablePointer<CChar>.allocate(capacity: 1)
    }

    func getAdapter<SectionID, ItemID>() -> TableViewAdapterBase<SectionID, ItemID> {
        if let adapter = typeErasedAdapter {
            precondition(adapter is TableViewAdapterBase<SectionID, ItemID>,
                         "Adapter type `\(type(of: adapter))` does not match the expected section and/or row ID type: \(SectionID.self) and \(ItemID.self).")
            return unsafeDowncast(adapter, to: TableViewAdapterBase<SectionID, ItemID>.self)
        }

        prepareForBoxRendering(sectionIdType: SectionID.self, rowIdType: ItemID.self)
        return getAdapter()
    }

    var typeErasedAdapter: AnyObject? {
        return objc_getAssociatedObject(self, AssociatedKey.adapter) as AnyObject?
    }
}
