import Bento
import UIKit

public final class CenterYCollectionViewLayout<SectioId: Hashable, NodeId: Hashable>: UICollectionViewLayout {
    private var contentHeight: CGFloat = 0
    private var cachedItemsAttributes = [IndexPath: UICollectionViewLayoutAttributes]()
    private var cachedHeaderAttributes = [IndexPath: UICollectionViewLayoutAttributes]()
    private var cachedFooterAttributes = [IndexPath: UICollectionViewLayoutAttributes]()
    public var box: Box<SectioId, NodeId> = .empty

    private var contentInset: UIEdgeInsets {
        if #available(iOS 11.0, *) {
            return collectionView?.adjustedContentInset ?? .zero
        } else {
            return collectionView?.contentInset ?? .zero
        }
    }

    public override init() {
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func prepare() {
        cachedItemsAttributes.removeAll()
        cachedHeaderAttributes.removeAll()
        cachedFooterAttributes.removeAll()
        contentHeight = 0
        setupAttributes()
    }

    public override var collectionViewContentSize: CGSize {
        guard let view = collectionView else { return .zero }

        return CGSize(width: view.bounds.width, height: contentHeight)
    }

    public override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return newBounds.size != (collectionView?.bounds.size ?? .zero)
    }

    public override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cachedItemsAttributes[indexPath]
    }

    public override func layoutAttributesForSupplementaryView(ofKind elementKind: String,
                                                              at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if elementKind == UICollectionView.elementKindSectionHeader {
            return cachedHeaderAttributes[indexPath]
        } else if elementKind == UICollectionView.elementKindSectionFooter {
            return cachedFooterAttributes[indexPath]
        }

        return nil
    }

    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
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

        let size = section.componentSize(of: .header, fittingWidth: view.bounds.width) ?? .zero

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
            let size = row.sizeBoundTo(width: view.bounds.width)

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

        let size = section.componentSize(of: .footer, fittingWidth: view.bounds.width) ?? .zero

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
