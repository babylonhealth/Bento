extension UITableView: BentoCollectionView {
    func indexPath(for cell: TableViewContainerCell) -> IndexPath? {
        return indexPath(for: cell as UITableViewCell)
    }

    func visibleCell(at indexPath: IndexPath) -> TableViewContainerCell? {
        return cellForRow(at: indexPath) as? TableViewContainerCell
    }

    func revealCell(at indexPath: IndexPath, animated: Bool) {
        scrollToRow(at: indexPath, at: .bottom, animated: false)
    }
}

extension UICollectionView: BentoCollectionView {
    func indexPath(for cell: CollectionViewContainerCell) -> IndexPath? {
        return indexPath(for: cell as UICollectionViewCell)
    }

    func visibleCell(at indexPath: IndexPath) -> CollectionViewContainerCell? {
        return cellForItem(at: indexPath) as? CollectionViewContainerCell
    }

    func revealCell(at indexPath: IndexPath, animated: Bool) {
        scrollToItem(at: indexPath, at: .bottom, animated: animated)
    }
}

extension TableViewContainerCell: BentoContainerCell {}
extension CollectionViewContainerCell: BentoContainerCell {}
