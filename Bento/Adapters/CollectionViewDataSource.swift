import FlexibleDiff
import UIKit

final class CollectionViewDataSource<SectionID: Hashable, ItemID: Hashable>
    : NSObject, UICollectionViewDataSource {
    private var sections: [Section<SectionID, ItemID>] = []
    private weak var collectionView: UICollectionView?
    private var knownSupplements: Set<Supplement> = []

    init(with collectionView: UICollectionView) {
        sections = []
        self.collectionView = collectionView
        super.init()
        collectionView.dataSource = self
         //Force reset of the collection view state to prevent inconsistency on first reload
        collectionView.reloadData()
        collectionView.layoutIfNeeded()
    }

    func update(sections: [Section<SectionID, ItemID>], animated: Bool = true) {
        guard let collectionView = collectionView else { return }
        if animated {
            let diff = CollectionViewSectionDiff(oldSections: self.sections,
                                                 newSections: sections,
                                                 knownSupplements: knownSupplements)
            self.sections = sections
            diff.apply(to: collectionView)
        } else {
            self.sections = sections
            collectionView.reloadData()
        }
    }

    func update(sections: [Section<SectionID, ItemID>], completion: (() -> Void)?) {
        guard let collectionView = collectionView else { return }

        let diff = CollectionViewSectionDiff(oldSections: self.sections,
                                             newSections: sections,
                                             knownSupplements: knownSupplements)
        self.sections = sections
        diff.apply(to: collectionView, completion: completion)
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sections[section].items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let component = node(at: indexPath).component
        let reuseIdentifier = component.reuseIdentifier
        collectionView.register(CollectionViewContainerCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CollectionViewContainerCell

        cell.bind(component)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let supplement = Supplement(collectionViewSupplementaryKind: kind)

        if let component = sections[indexPath.section].supplements[supplement] {
            knownSupplements.insert(supplement)

            let reuseIdentifier = component.reuseIdentifier
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
        } else {
            return UICollectionReusableView()
        }
    }

    private func node(at indexPath: IndexPath) -> Node<ItemID> {
        return sections[indexPath.section].items[indexPath.row]
    }
}
