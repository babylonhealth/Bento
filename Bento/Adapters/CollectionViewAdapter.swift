import FlexibleDiff
import UIKit

private let emptyReuseIdentifier = "_bento_empty"

public typealias CollectionViewAdapter<SectionID: Hashable, ItemID: Hashable> = CollectionViewAdapterBase<SectionID, ItemID> & UICollectionViewDataSource & UICollectionViewDelegate

open class CollectionViewAdapterBase<SectionID: Hashable, ItemID: Hashable>
    : NSObject, FocusEligibilitySourceImplementing {
    public private(set) var sections: [Section<SectionID, ItemID>] = []

    internal private(set) weak var collectionView: UICollectionView?
    private var knownSupplements: Set<Supplement> = []

    public init(with collectionView: UICollectionView) {
        sections = []
        self.collectionView = collectionView
        super.init()
    }

    internal func update(sections: [Section<SectionID, ItemID>], animated: Bool, completion: (() -> Void)?) {
        guard let collectionView = collectionView else { return }

        if !animated || collectionView.window == nil {
            // Just reload collection view if it's not in the window hierarchy
            self.sections = sections
            collectionView.reloadData()
            completion?()
            return
        }

        let diff = CollectionViewSectionDiff(oldSections: self.sections,
                                             newSections: sections,
                                             knownSupplements: knownSupplements)
        diff.apply(to: collectionView, updateAdapter: { self.sections = sections }, completion: completion)
    }

    @objc(numberOfSectionsInCollectionView:)
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }

    @objc(collectionView:numberOfItemsInSection:)
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sections[section].items.count
    }

    @objc(collectionView:cellForItemAtIndexPath:)
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let component = node(at: indexPath).component
        let reuseIdentifier = component.fullyQualifiedTypeName
        collectionView.register(CollectionViewContainerCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CollectionViewContainerCell

        cell.bind(component)
        return cell
    }

    @objc(collectionView:viewForSupplementaryElementOfKind:atIndexPath:)
    open func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let supplement = Supplement(collectionViewSupplementaryKind: kind)
        knownSupplements.insert(supplement)

        let component = sections[indexPath.section].supplements[supplement]
        let reuseIdentifier = component?.fullyQualifiedTypeName ?? emptyReuseIdentifier

        collectionView.register(CollectionViewContainerReusableView.self,
                                forSupplementaryViewOfKind: kind,
                                withReuseIdentifier: reuseIdentifier)

        let view = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: reuseIdentifier,
            for: indexPath
        ) as! CollectionViewContainerReusableView

        view.bind(component)
        return view
    }

    @objc(collectionView:willDisplayCell:forItemAtIndexPath:)
    open func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? BentoReusableView else { return }
        cell.willDisplayView()
    }

    @objc(collectionView:willDisplaySupplementaryView:forElementKind:atIndexPath:)
    open func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        guard let view = view as? BentoReusableView else { return }
        view.willDisplayView()
    }

    @objc(collectionView:didEndDisplayingCell:forItemAtIndexPath:)
    open func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? BentoReusableView else { return }
        cell.didEndDisplayingView()
    }

    @objc(collectionView:didEndDisplayingSupplementaryView:forElementOfKind:atIndexPath:)
    open func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
        guard let view = view as? BentoReusableView else { return }
        view.didEndDisplayingView()
    }

    @objc(collectionView:shouldShowMenuForItemAtIndexPath:)
    open func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        guard let component = sections[indexPath.section].items[indexPath.row].component(as: MenuItemsResponding.self) else {
            return false
        }
        UIMenuController.shared.menuItems = component.menuItems
        return true
    }

    @objc(collectionView:canPerformAction:forItemAtIndexPath:withSender:)
    open func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath?, withSender sender: Any?) -> Bool {
        guard let indexPath = indexPath else { return false }
        return self.collectionView(collectionView, canPerformAction: action, forItemAt: indexPath, withSender: sender)
    }
    
    open func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        guard let component = sections[indexPath.section].items[indexPath.row].component(as: MenuItemsResponding.self) else {
                return false
        }
        
        return component.responds(to: action)
    }

    @objc(collectionView:performAction:forItemAtIndexPath:withSender:)
    open func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {}

    private func node(at indexPath: IndexPath) -> Node<ItemID> {
        return sections[indexPath.section].items[indexPath.row]
    }
}

internal final class BentoCollectionViewAdapter<SectionID: Hashable, ItemID: Hashable>
    : CollectionViewAdapterBase<SectionID, ItemID>,
    UICollectionViewDataSource,
    UICollectionViewDelegate
{}
