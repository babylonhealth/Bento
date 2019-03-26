import UIKit

open class SizeCachingCollectionView: UICollectionView {
    public convenience init<SectionID: Hashable, ItemID: Hashable>(
        frame: CGRect,
        layout: UICollectionViewLayout,
        sectionIDType: SectionID.Type,
        itemIDType: ItemID.Type
    ) {
        self.init(frame: frame, layout: layout, adapterClass: BentoCollectionViewAdapter<SectionID, ItemID>.self)
    }

    public init<SectionID, ItemID>(
        frame: CGRect,
        layout: UICollectionViewLayout,
        adapterClass: CollectionViewAdapter<SectionID, ItemID>.Type
    ) {
        super.init(frame: frame, collectionViewLayout: layout)
        prepareForBoxRendering(with: adapterClass.init(with: self))
        adapterStore.cachesSizeInformation = true
    }

    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("`BentoTableView` does not support Interface Builder or Storyboard.")
    }

    open override func layoutSubviews() {
        adapterStore.boundSize = bounds.size
        super.layoutSubviews()
    }
}
