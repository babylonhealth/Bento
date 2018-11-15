import Bento
import UIKit

final class StickyFooterCollectionViewLayout<SectioId: Hashable, NodeId: Hashable>: UICollectionViewLayout {
    var box: Box<SectioId, NodeId> = .empty
    private var contentHeight: CGFloat = 0
    private let cache = BentoCollectionViewCache<SectioId, NodeId>()
    private var cachedItemsAttributes = [IndexPath: UICollectionViewLayoutAttributes]()
    private var cachedHeaderAttributes = [IndexPath: UICollectionViewLayoutAttributes]()
    private var cachedFooterAttributes = [IndexPath: UICollectionViewLayoutAttributes]()
    private var lastFooterAttributes: UICollectionViewLayoutAttributes?

    private var contentInset: UIEdgeInsets {
        if #available(iOS 11.0, *) {
            return collectionView?.adjustedContentInset ?? .zero
        } else {
            return collectionView?.contentInset ?? .zero
        }
    }

    override func prepare() {
        cachedItemsAttributes.removeAll()
        cachedHeaderAttributes.removeAll()
        cachedFooterAttributes.removeAll()
        cache.clean()
        contentHeight = 0
        setupAttributes()
    }

    override var collectionViewContentSize: CGSize {
        guard let view = collectionView else { return .zero }

        return CGSize(width: view.bounds.width, height: contentHeight)
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cachedItemsAttributes[indexPath]
    }

    override func layoutAttributesForSupplementaryView(ofKind elementKind: String,
                                                       at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if elementKind == UICollectionView.elementKindSectionHeader {
            return cachedHeaderAttributes[indexPath]
        } else if elementKind == UICollectionView.elementKindSectionFooter {
            return cachedFooterAttributes[indexPath]
        }

        return nil
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let headers = cachedHeaderAttributes.filter { (_, attribute) -> Bool in
            return rect.intersects(attribute.frame)
            }.values

        let footers = cachedFooterAttributes.filter { (_, attribute) -> Bool in
            return rect.intersects(attribute.frame)
            }.values

        let items = cachedItemsAttributes.filter { (_, attibute) -> Bool in
            return rect.intersects(attibute.frame)
            }
            .values

        return Array([
            Array(headers),
            Array(footers),
            Array(items)
            ]
            .joined())
    }

    private func setupAttributes() {
        guard let view = collectionView else { return }

        for index in 0..<view.numberOfSections {
            let section = box.sections[index]
            setupHeaderAttributes(for: section, at: index)
            setupRowsAttribute(for: section, at: index)
            setupFooterAttributes(for: section, at: index)
        }
        
        updateLastFooterAttributes()
    }

    private func setupHeaderAttributes(for section: Section<SectioId, NodeId>, at index: Int) {
        let indexPath = IndexPath(row: index, section: index)
        let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                                          with: indexPath)
        let size = cache.sizeForHeader(of: section, width: collectionView?.bounds.width ?? 0)

        attributes.frame = CGRect(origin: CGPoint(x: 0, y: contentHeight), size: size)
        cachedHeaderAttributes[indexPath] = attributes
        contentHeight += size.height
    }

    private func setupRowsAttribute(for section: Section<SectioId, NodeId>, at index: Int) {
        guard let view = collectionView else { return }

        for rowIdx in 0..<view.numberOfItems(inSection: index) {
            let row = section.items[rowIdx]
            let indexPath = IndexPath(row: rowIdx, section: index)
            let attribute = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            let size = cache.sizeForNode(row, width: view.bounds.width)

            attribute.frame = CGRect(origin: CGPoint(x: 0, y: contentHeight), size: size)
            contentHeight += size.height
            cachedItemsAttributes[indexPath] = attribute
        }
    }

    private func setupFooterAttributes(for section: Section<SectioId, NodeId>, at index: Int) {
        let numberOfSections = collectionView?.numberOfSections ?? 0
        let indexPath = IndexPath(row: index, section: index)
        let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                                                          with: indexPath)
        let size = cache.sizeForFooter(of: section, width: collectionView?.bounds.width ?? 0)

        attributes.frame = CGRect(origin: CGPoint(x: 0, y: contentHeight), size: size)
        cachedFooterAttributes[indexPath] = attributes
        contentHeight += size.height

        if index == numberOfSections - 1 {
            attributes.zIndex = Int.max
            lastFooterAttributes = attributes
        }
    }

    private func updateLastFooterAttributes() {
        guard let view = collectionView else { return }
        let footerHeight = lastFooterAttributes?.bounds.size.height ?? 0
        let y = view.contentOffset.y + view.bounds.height - footerHeight - contentInset.bottom
        lastFooterAttributes?.frame.origin.y = y
    }
}
