import FlexibleDiff
import UIKit

final class CollectionViewDataSource<SectionId: Hashable, ItemId: Hashable>
    : NSObject, UICollectionViewDataSource {
    private let emptyHeaderFooterReuseID = "Bento.CollectionViewDataSource.emptyHeaderFooterReuseID"
    private var sections: [Section<SectionId, ItemId>] = []
    private weak var collectionView: UICollectionView?

    init(with collectionView: UICollectionView) {
        sections = []
        self.collectionView = collectionView
        super.init()
        collectionView.dataSource = self
         //Force reset of the collection view state to prevent inconsistency on first reload
        collectionView.reloadData()
        collectionView.layoutIfNeeded()
    }

    func update(sections: [Section<SectionId, ItemId>], animated: Bool = true) {
        guard let collectionView = collectionView else { return }
        if animated {
            let diff = CollectionViewSectionDiff(oldSections: self.sections,
                                                 newSections: sections)
            self.sections = sections
            diff.apply(to: collectionView)
        } else {
            self.sections = sections
            collectionView.reloadData()
        }
    }

    func update(sections: [Section<SectionId, ItemId>], completion: (() -> Void)?) {
        guard let collectionView = collectionView else { return }

        let diff = CollectionViewSectionDiff(oldSections: self.sections,
                                             newSections: sections)
        self.sections = sections
        diff.apply(to: collectionView, completion: completion)
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sections[section].rows.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let component = node(at: indexPath).component
        collectionView.register(CollectionViewContainerCell.self, forCellWithReuseIdentifier: component.reuseIdentifier)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: component.reuseIdentifier, for: indexPath) as! CollectionViewContainerCell

        let componentView: UIView
        if let containedView = cell.containedView {
            componentView = containedView
        } else {
            componentView = component.generate()
            cell.install(view: componentView)
        }
        component.render(in: componentView)
        return cell
    }

    public func collectionView(_ collectionView: UICollectionView,
                               viewForSupplementaryElementOfKind kind: String,
                               at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            return setupHeader(for: collectionView, at: indexPath)
        } else {
            return setupFooter(for: collectionView, at: indexPath)
        }
    }

    private func node(at indexPath: IndexPath) -> Node<ItemId> {
        return sections[indexPath.section].rows[indexPath.row]
    }

    private func setupHeader(for collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let component = sections[indexPath.section].header else {
            collectionView.register(CollectionViewSupplementaryView.self,
                                    forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
                                    withReuseIdentifier: emptyHeaderFooterReuseID)
            return collectionView.dequeueReusableSupplementaryView(
                ofKind: UICollectionElementKindSectionHeader,
                withReuseIdentifier: emptyHeaderFooterReuseID,
                for: indexPath
            )
        }
        collectionView.register(CollectionViewSupplementaryView.self,
                                forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
                                withReuseIdentifier: component.reuseIdentifier)
        let cell = collectionView.dequeueReusableSupplementaryView(
            ofKind: UICollectionElementKindSectionHeader,
            withReuseIdentifier: component.reuseIdentifier,
            for: indexPath
            ) as! CollectionViewSupplementaryView

        let componentView: UIView
        if let containedView = cell.containedView {
            componentView = containedView
        } else {
            componentView = component.generate()
            cell.install(view: componentView)
        }
        component.render(in: componentView)

        return cell
    }

    private func setupFooter(for collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let component = sections[indexPath.section].footer else {
            collectionView.register(CollectionViewSupplementaryView.self,
                                    forSupplementaryViewOfKind: UICollectionElementKindSectionFooter,
                                    withReuseIdentifier: emptyHeaderFooterReuseID)
            return collectionView.dequeueReusableSupplementaryView(
                ofKind: UICollectionElementKindSectionFooter,
                withReuseIdentifier: emptyHeaderFooterReuseID,
                for: indexPath
            )
        }
        collectionView.register(CollectionViewSupplementaryView.self,
                                forSupplementaryViewOfKind: UICollectionElementKindSectionFooter,
                                withReuseIdentifier: component.reuseIdentifier)
        let cell = collectionView.dequeueReusableSupplementaryView(
            ofKind: UICollectionElementKindSectionFooter,
            withReuseIdentifier: component.reuseIdentifier,
            for: indexPath
        ) as! CollectionViewSupplementaryView

        let componentView: UIView
        if let containedView = cell.containedView {
            componentView = containedView
        } else {
            componentView = component.generate()
            cell.install(view: componentView)
        }
        component.render(in: componentView)

        return cell
    }
}
