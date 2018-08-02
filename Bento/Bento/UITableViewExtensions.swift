extension UITableView {
    public func prepareForBoxRendering<SectionId: Hashable, RowId: Hashable>(
        sectionIdType: SectionId.Type,
        rowIdType: RowId.Type
    ) {
        prepareForBoxRendering(with: BentoTableViewAdapter<SectionId, RowId>(with: self))
    }

    public func prepareForBoxRendering<SectionId, RowId>(
        with adapter: TableViewAdapter<SectionId, RowId>
    ) {
        precondition(typeErasedAdapter == nil, "Preparation must happen before any Bento `Box` rendering occurrence.")
        precondition(adapter.tableView == self, "The custom adapter is not created for the table view it is deployed to.")

        self.delegate = adapter
        self.dataSource = adapter
        reloadData()
        layoutIfNeeded()
        objc_setAssociatedObject(self, AssociatedKey.adapter, adapter, .OBJC_ASSOCIATION_RETAIN)
    }

    public func render<SectionId, RowId>(_ box: Box<SectionId, RowId>) {
        render(box, animated: true)
    }

    public func render<SectionId, RowId>(_ box: Box<SectionId, RowId>, animated: Bool) {
        let adapter: TableViewAdapterBase<SectionId, RowId> = getAdapter()
        if animated {
            adapter.update(sections: box.sections, with: TableViewAnimation())
        } else {
            adapter.update(sections: box.sections)
        }
        didRenderBox()
    }

    public func render<SectionId, RowId>(_ box: Box<SectionId, RowId>, with animation: TableViewAnimation) {
        let adapter: TableViewAdapterBase<SectionId, RowId> = getAdapter()

        adapter.update(sections: box.sections, with: animation)
        didRenderBox()
    }

    private struct AssociatedKey {
        static let adapter = UnsafeMutablePointer<CChar>.allocate(capacity: 1)
    }

    func getAdapter<SectionId, RowId>() -> TableViewAdapterBase<SectionId, RowId> {
        if let adapter = typeErasedAdapter {
            precondition(adapter is TableViewAdapterBase<SectionId, RowId>,
                         "Adapter type `\(type(of: adapter))` does not match the expected section and/or row ID type: \(SectionId.self) and \(RowId.self).")
            return unsafeDowncast(adapter, to: TableViewAdapterBase<SectionId, RowId>.self)
        }

        prepareForBoxRendering(sectionIdType: SectionId.self, rowIdType: RowId.self)
        return getAdapter()
    }

    var typeErasedAdapter: AnyObject? {
        return objc_getAssociatedObject(self, AssociatedKey.adapter) as AnyObject?
    }
}
