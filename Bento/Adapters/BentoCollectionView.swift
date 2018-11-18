internal protocol BentoContainerCell {
    var containedView: UIView? { get }
}

internal protocol BentoCollectionView: FocusCoordinatorProviding {
    associatedtype Cell: BentoContainerCell
    associatedtype DataSource

    var dataSource: DataSource? { get }

    func indexPath(for cell: Cell) -> IndexPath?
    func visibleCell(at indexPath: IndexPath) -> Cell?
    func revealCell(at indexPath: IndexPath, animated: Bool)

    func insertSections(_ sections: IndexSet)
    func deleteSections(_ sections: IndexSet)
    func moveSection(_ source: Int, toSection destination: Int)
    func insertItems(at indexPaths: [IndexPath])
    func deleteItems(at indexPaths: [IndexPath])
    func moveItem(at source: IndexPath, to destination: IndexPath)
    func updateSupplements<SectionID, ItemID, ItemMutations: Collection>(_ supplements: Set<Supplement>, diffMutations: ItemMutations, newSections: [Section<SectionID, ItemID>]) where ItemMutations.Element == (source: Int, destination: Int)

    func batchUpdate(_ update: @escaping () -> Void, completion: ((Bool) -> Void)?)
    
}

extension BentoCollectionView {
    func didRenderBox() {
        UIApplication.shared.sendAction(#selector(FocusableView.neighboringFocusEligibilityDidChange),
                                        to: nil,
                                        from: self,
                                        for: nil)
    }
}
