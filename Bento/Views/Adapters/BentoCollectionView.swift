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
}

extension BentoCollectionView {
    func didRenderBox() {
        UIApplication.shared.sendAction(#selector(FocusableView.neighboringFocusEligibilityDidChange),
                                        to: nil,
                                        from: self,
                                        for: nil)
    }
}
