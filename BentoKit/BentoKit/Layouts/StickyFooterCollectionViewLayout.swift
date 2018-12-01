import Bento
import UIKit

public final class StickyFooterCollectionViewLayout<SectioId: Hashable, NodeId: Hashable>: BoxLayout<SectioId, NodeId> {
    public var shouldPinFirstSection = true
    public var shouldPinLastSection = true
    
    private var contentHeight: CGFloat = 0
    private let cache = BentoCollectionViewCache<SectioId, NodeId>()
    private var cachedItemsAttributes = [IndexPath: UICollectionViewLayoutAttributes]()
    private var cachedHeaderAttributes = [IndexPath: UICollectionViewLayoutAttributes]()
    private var cachedFooterAttributes = [IndexPath: UICollectionViewLayoutAttributes]()
    private var firstSectionAttributes = [UICollectionViewLayoutAttributes]()
    private var lastSectionAttributes = [UICollectionViewLayoutAttributes]()

    private var contentInset: UIEdgeInsets {
        if #available(iOS 11.0, *) {
            return collectionView?.adjustedContentInset ?? .zero
        } else {
            return collectionView?.contentInset ?? .zero
        }
    }

    override public func prepare() {
        precondition(box.sections.count >= 2)
        cachedItemsAttributes.removeAll()
        cachedHeaderAttributes.removeAll()
        cachedFooterAttributes.removeAll()
        firstSectionAttributes.removeAll()
        lastSectionAttributes.removeAll()
        cache.clean()
        contentHeight = 0
        setupAttributes()
    }

    override public var collectionViewContentSize: CGSize {
        guard let view = collectionView else { return .zero }

        return CGSize(width: view.bounds.width, height: contentHeight)
    }

    override public func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }

    override public func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cachedItemsAttributes[indexPath]
    }

    override public func layoutAttributesForSupplementaryView(ofKind elementKind: String,
                                                       at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if elementKind == UICollectionView.elementKindSectionHeader {
            return cachedHeaderAttributes[indexPath]
        } else if elementKind == UICollectionView.elementKindSectionFooter {
            return cachedFooterAttributes[indexPath]
        }

        return nil
    }

    override public func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
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
        for index in 0..<box.sections.count {
            let section = box.sections[index]
            setupHeaderAttributes(for: section, at: index)
            setupRowsAttribute(for: section, at: index)
            setupFooterAttributes(for: section, at: index)
        }
        
        if shouldPinFirstSection {
            adjustFirstSectionAttributes()
        }
        if shouldPinLastSection {
            adjustLastSectionAttributes()
        }
    }

    private func setupHeaderAttributes(for section: Section<SectioId, NodeId>, at index: Int) {
        let numberOfSections = box.sections.count
        let indexPath = IndexPath(row: index, section: index)
        let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                                          with: indexPath)
        let size = cache.sizeForHeader(of: section, width: collectionView?.bounds.width ?? 0)

        attributes.frame = CGRect(origin: CGPoint(x: 0, y: contentHeight), size: size)
        cachedHeaderAttributes[indexPath] = attributes
        contentHeight += size.height
        
        if index == 0 {
            firstSectionAttributes.append(attributes)
        }
        if index == numberOfSections - 1 {
            lastSectionAttributes.append(attributes)
        }
    }

    private func setupRowsAttribute(for section: Section<SectioId, NodeId>, at index: Int) {
        let numberOfSections = box.sections.count
        
        for rowIdx in 0..<section.items.count {
            let row = section.items[rowIdx]
            let indexPath = IndexPath(row: rowIdx, section: index)
            let attribute = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            let size = cache.sizeForNode(row, width: collectionView?.bounds.width ?? 0)

            attribute.frame = CGRect(origin: CGPoint(x: 0, y: contentHeight), size: size)
            contentHeight += size.height
            cachedItemsAttributes[indexPath] = attribute
            
            if index == 0 {
                firstSectionAttributes.append(attribute)
            }
            if index == numberOfSections - 1 {
                lastSectionAttributes.append(attribute)
            }
        }
    }

    private func setupFooterAttributes(for section: Section<SectioId, NodeId>, at index: Int) {
        let numberOfSections = box.sections.count
        let indexPath = IndexPath(row: index, section: index)
        let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                                                          with: indexPath)
        let size = cache.sizeForFooter(of: section, width: collectionView?.bounds.width ?? 0)

        attributes.frame = CGRect(origin: CGPoint(x: 0, y: contentHeight), size: size)
        cachedFooterAttributes[indexPath] = attributes
        contentHeight += size.height

        if index == 0 {
            firstSectionAttributes.append(attributes)
        }
        if index == numberOfSections - 1 {
            lastSectionAttributes.append(attributes)
        }
    }
    
    private func adjustFirstSectionAttributes() {
        guard let view = collectionView else { return }
        
        var y: CGFloat = contentInset.top
            + view.contentOffset.y
        for attribute in firstSectionAttributes {
            attribute.zIndex = Int.max
            attribute.frame.origin.y = y
            y += attribute.bounds.height
        }
    }

    private func adjustLastSectionAttributes() {
        guard let view = collectionView else { return }
        let lastSectionHeight = lastSectionAttributes.reduce(0) { (height, attributes) in
            return height + attributes.bounds.height
        }
        var y = view.contentOffset.y
            + view.bounds.height
            - lastSectionHeight
            - contentInset.bottom
        for attribute in lastSectionAttributes {
            attribute.zIndex = Int.max
            attribute.frame.origin.y = y
            y += attribute.bounds.height
        }
    }
}
