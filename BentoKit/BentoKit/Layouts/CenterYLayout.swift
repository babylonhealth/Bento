import Bento
import UIKit

public final class CenterYLayout<SectioId: Hashable, NodeId: Hashable>: BoxLayout<SectioId, NodeId> {
    private var contentHeight: CGFloat = 0
    private let cache = BentoCollectionViewCache<SectioId, NodeId>()
    private var cachedItemsAttributes = [IndexPath: UICollectionViewLayoutAttributes]()
    private var cachedHeaderAttributes = [IndexPath: UICollectionViewLayoutAttributes]()
    private var cachedFooterAttributes = [IndexPath: UICollectionViewLayoutAttributes]()

    private var contentInset: UIEdgeInsets {
        if #available(iOS 11.0, *) {
            return collectionView?.adjustedContentInset ?? .zero
        } else {
            return collectionView?.contentInset ?? .zero
        }
    }

    override public func prepare() {
        cachedItemsAttributes.removeAll()
        cachedHeaderAttributes.removeAll()
        cachedFooterAttributes.removeAll()
        cache.clean()
        contentHeight = 0
        setupAttributes()
    }

    override public var collectionViewContentSize: CGSize {
        guard let view = collectionView else { return .zero }

        return CGSize(width: view.bounds.width, height: contentHeight)
    }

    override public func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return newBounds.size != (collectionView?.bounds.size ?? .zero)
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
        adjustAttributes()
    }

    private func setupHeaderAttributes(for section: Section<SectioId, NodeId>, at index: Int) {
        guard let view = collectionView else { return }

        let indexPath = IndexPath(row: index, section: index)
        let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                                          with: indexPath)

        let size = cache.sizeForHeader(of: section, width: view.bounds.width)

        attributes.frame = CGRect(origin: CGPoint(x: 0, y: contentHeight), size: size)

        cachedHeaderAttributes[indexPath] = attributes
        contentHeight += size.height
    }

    private func setupRowsAttribute(for section: Section<SectioId, NodeId>, at index: Int) {
        guard let view = collectionView else { return }

        for rowIdx in 0..<section.items.count {
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
        guard let view = collectionView else { return }

        let indexPath = IndexPath(row: index, section: index)
        let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                                                          with: indexPath)

        let size = cache.sizeForFooter(of: section, width: view.bounds.width)

        attributes.frame = CGRect(origin: CGPoint(x: 0, y: contentHeight), size: size)

        cachedFooterAttributes[indexPath] = attributes
        contentHeight += size.height
    }

    private func adjustAttributes() {
        guard let view = collectionView else { return }

        let topInset = ceil((view.bounds.height - contentInset.top - contentInset.bottom - contentHeight) / 2)

        for attribute in [cachedItemsAttributes.values, cachedFooterAttributes.values, cachedHeaderAttributes.values].joined() {
            attribute.frame.origin.y += topInset
        }
    }
}

final class BentoCollectionViewCache<SectionId: Hashable, NodeId: Hashable> {
    private let itemSizeCache = SizeCache<NodeId>()
    private let headerSizeCache = SizeCache<SectionId>()
    private let footerSizeCache = SizeCache<SectionId>()

    func sizeForNode(_ node: Node<NodeId>, width: CGFloat) -> CGSize {
        guard let size = itemSizeCache.size(forId: node.id, width: width) else {
            var size = node.sizeBoundTo(width: width)
            size.height = ceil(size.height)
            itemSizeCache.set(size: size, forId: node.id, width: width)

            return size
        }

        return size
    }

    func sizeForHeader(of section: Section<SectionId, NodeId>, width: CGFloat) -> CGSize {
        guard let size = headerSizeCache.size(forId: section.id, width: width) else {
            var size = section.componentSize(of: .header, fittingWidth: width, inheritedMargins: .zero) ?? .zero
            size.height = ceil(size.height)
            headerSizeCache.set(size: size, forId: section.id, width: width)

            return size
        }

        return size
    }

    func sizeForFooter(of section: Section<SectionId, NodeId>, width: CGFloat) -> CGSize {
        guard let size = footerSizeCache.size(forId: section.id, width: width) else {
            var size = section.componentSize(of: .footer, fittingWidth: width, inheritedMargins: .zero) ?? .zero
            size.height = ceil(size.height)
            footerSizeCache.set(size: size, forId: section.id, width: width)

            return size
        }

        return size
    }

    func clean() {
        itemSizeCache.clean()
        headerSizeCache.clean()
        footerSizeCache.clean()
    }

    private class SizeCache<Id: Hashable> {
        private struct Key: Hashable {
            let id: Id
            let width: CGFloat
        }

        private var cache: [Key: CGSize] = [:]

        func size(forId id: Id, width: CGFloat) -> CGSize? {
            return cache[Key(id: id, width: width)]
        }

        func set(size: CGSize, forId id: Id, width: CGFloat) {
            cache[Key(id: id, width: width)] = size
        }

        func clean() {
            cache = [:]
        }
    }
}
