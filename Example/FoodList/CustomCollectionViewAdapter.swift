import Bento

class CustomCollectionViewAdapter<SectionID: Hashable, ItemID: Hashable>
    : CollectionViewAdapterBase<SectionID, ItemID>,
      UICollectionViewDataSource,
      UICollectionViewDelegate {
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        super.collectionView(collectionView, willDisplay: cell, forItemAt: indexPath)
        print("Custom Adapter: Will Display Cell at \(indexPath)")
    }

    override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        super.collectionView(collectionView, didEndDisplaying: cell, forItemAt: indexPath)
        print("Custom Adapter: Did End Displaying Cell at \(indexPath)")
    }
}
