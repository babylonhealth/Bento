import UIKit

open class SizeCachingTableView: UITableView {
    public convenience init<SectionID: Hashable, ItemID: Hashable>(
        frame: CGRect,
        style: UITableView.Style,
        sectionIDType: SectionID.Type,
        itemIDType: ItemID.Type
    ) {
        self.init(frame: frame, style: style, adapterClass: BentoTableViewAdapter<SectionID, ItemID>.self)
    }

    public init<SectionID, ItemID>(
        frame: CGRect,
        style: UITableView.Style,
        adapterClass: TableViewAdapter<SectionID, ItemID>.Type
    ) {
        super.init(frame: frame, style: style)
        prepareForBoxRendering(with: adapterClass.init(with: self))
        adapterStore.cachesSizeInformation = true
    }

    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("`BentoTableView` does not support Interface Builder or Storyboard.")
    }

    open override func layoutMarginsDidChange() {
        super.layoutMarginsDidChange()
        adapterStore.layoutMargins = UIEdgeInsets(
            top: 0,
            left: layoutMargins.left,
            bottom: 0,
            right: layoutMargins.right
        )
    }

    open override func layoutSubviews() {
        adapterStore.boundSize = bounds.size
        super.layoutSubviews()
    }
}
