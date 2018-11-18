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
    
    func insertSections(_ sections: IndexSet) {
        insertSections(sections, with: animationOptions.sectionInsertion)
    }
    
    func deleteSections(_ sections: IndexSet) {
        deleteSections(sections, with: animationOptions.sectionDeletion)
    }
    
    func insertItems(at indexPaths: [IndexPath]) {
        insertRows(at: indexPaths, with: animationOptions.rowInsertion)
    }
    
    func deleteItems(at indexPaths: [IndexPath]) {
        deleteRows(at: indexPaths, with: animationOptions.rowDeletion)
    }
    
    func moveItem(at source: IndexPath, to destination: IndexPath) {
        moveRow(at: source, to: destination)
    }
    
    func batchUpdate(_ update: @escaping () -> Void, completion: ((Bool) -> Void)?) {
        if #available(iOS 11.0, *) {
            performBatchUpdates(update, completion: completion)
        } else {
            precondition(completion == nil, "Completion block is not supported on iOS 10.")
            beginUpdates()
            update()
            endUpdates()
        }
    }
    
    func updateSupplements<SectionID, ItemID, ItemMutations: Collection>(_ supplements: Set<Supplement>, diffMutations: ItemMutations, newSections: [Section<SectionID, ItemID>]) where ItemMutations.Element == (source: Int, destination: Int) {
        for (source, destination) in diffMutations {
            if let headerView = headerView(forSection: source) {
                let component = newSections[destination].supplements[.header]
                (headerView as? BentoReusableView)?.bind(component)
            }
            
            if let footerView = footerView(forSection: source) {
                let component = newSections[destination].supplements[.footer]
                (footerView as? BentoReusableView)?.bind(component)
            }
        }
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
    
    func batchUpdate(_ update: @escaping () -> Void, completion: ((Bool) -> Void)?) {
        performBatchUpdates(update, completion: completion)
    }
    
    func updateSupplements<SectionID, ItemID, ItemMutations: Collection>(_ supplements: Set<Supplement>, diffMutations: ItemMutations, newSections: [Section<SectionID, ItemID>]) where ItemMutations.Element == (source: Int, destination: Int) {
        for supplement in supplements {
            let elementKind = supplement.elementKind
            
            let groups = Dictionary(
                grouping: indexPathsForVisibleSupplementaryElements(ofKind: elementKind),
                by: { $0.section }
            )
            
            for (source, destination) in diffMutations {
                if let indexPaths = groups[source] {
                    for indexPath in indexPaths {
                        let view = supplementaryView(forElementKind: elementKind, at: indexPath)
                        let component = newSections[destination].supplements[supplement]
                        (view as? BentoReusableView)?.bind(component)
                    }
                }
            }
        }
    }
}

extension TableViewContainerCell: BentoContainerCell {}
extension CollectionViewContainerCell: BentoContainerCell {}
