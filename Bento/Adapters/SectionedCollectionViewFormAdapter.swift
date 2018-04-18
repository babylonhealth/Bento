import UIKit
import FlexibleDiff

final class SectionedCollectionViewFormAdapter<SectionId: Hashable, ItemId: Hashable>
: NSObject, UICollectionViewDataSource, UICollectionViewDelegate {
    private var sections: [Section<SectionId, ItemId>] = []
    private weak var collectionView: UICollectionView?

    init(with collectionView: UICollectionView) {
        self.sections = []
        self.collectionView = collectionView
        super.init()
        collectionView.dataSource = self
        collectionView.delegate = self
    }

    func update(sections: [Section<SectionId, ItemId>], animated: Bool = true) {
        if animated {
            guard let collectionView = collectionView else { return }

            let diff = CollectionViewSectionDiff(oldSections: self.sections,
                                                 newSections: sections)
            self.sections = sections
            diff.apply(to: collectionView)
        } else {
            self.sections = sections
            collectionView?.reloadData()
        }
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sections[section].rows.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let component = node(at: indexPath).component
        let reuseIdentifier = component.reuseIdentifier
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? CollectionViewCell else {
            collectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
            return self.collectionView(collectionView, cellForItemAt: indexPath)
        }

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

    private func node(at indexPath: IndexPath) -> Node<ItemId> {
        return sections[indexPath.section].rows[indexPath.row]
    }
}
