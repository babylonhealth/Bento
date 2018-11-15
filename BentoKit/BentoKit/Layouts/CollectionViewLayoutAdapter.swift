import Bento
import UIKit

public final class BoxCollectionViewLayoutProxy<SectionId: Hashable, NodeId: Hashable>: UICollectionViewLayout {
    private var layout = BoxLayout<SectionId, NodeId>()
    
    public override var developmentLayoutDirection: UIUserInterfaceLayoutDirection {
        return layout.developmentLayoutDirection
    }
    
    public override var flipsHorizontallyInOppositeLayoutDirection: Bool {
        return layout.flipsHorizontallyInOppositeLayoutDirection
    }
    
    public override init() {
        super.init()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func render(box: Box<SectionId, NodeId>, layout: BoxLayout<SectionId, NodeId>) {
        self.layout = layout
        self.layout.box = box
        self.layout.update(collectionView: collectionView)
        collectionView?.render(box)
    }
    
    public override func prepare() {
        layout.prepare()
    }
    
    public override func invalidateLayout() {
        layout.invalidateLayout()
    }
    
    public override func invalidateLayout(with context: UICollectionViewLayoutInvalidationContext) {
        layout.invalidateLayout(with: context)
    }
    
    public override var collectionViewContentSize: CGSize {
        return layout.collectionViewContentSize
    }
    
    public override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return layout.shouldInvalidateLayout(forBoundsChange: newBounds)
    }
    
    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return layout.layoutAttributesForElements(in: rect)
    }
    
    public override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return layout.layoutAttributesForItem(at: indexPath)
    }
    
    public override func layoutAttributesForSupplementaryView(ofKind elementKind: String,
                                                              at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return layout.layoutAttributesForSupplementaryView(ofKind: elementKind, at: indexPath)
    }
    
    public override func layoutAttributesForDecorationView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return layout.layoutAttributesForDecorationView(ofKind: elementKind, at: indexPath)
    }
    
    public override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
        return layout.invalidationContext(forBoundsChange: newBounds)
    }
    
    public override func shouldInvalidateLayout(forPreferredLayoutAttributes preferredAttributes: UICollectionViewLayoutAttributes, withOriginalAttributes originalAttributes: UICollectionViewLayoutAttributes) -> Bool {
        return layout.shouldInvalidateLayout(forPreferredLayoutAttributes: preferredAttributes, withOriginalAttributes: originalAttributes)
    }
    
    public override func invalidationContext(forPreferredLayoutAttributes preferredAttributes: UICollectionViewLayoutAttributes, withOriginalAttributes originalAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutInvalidationContext {
        return layout.invalidationContext(forPreferredLayoutAttributes: preferredAttributes, withOriginalAttributes: originalAttributes)
    }
    
    public override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        return layout.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
    }
    
    public override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        return layout.targetContentOffset(forProposedContentOffset: proposedContentOffset)
    }
    
    public override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
        layout.prepare(forCollectionViewUpdates: updateItems)
    }
    
    public override func finalizeCollectionViewUpdates() {
        layout.finalizeCollectionViewUpdates()
    }
    
    public override func prepare(forAnimatedBoundsChange oldBounds: CGRect) {
        layout.prepare(forAnimatedBoundsChange: oldBounds)
    }
    
    public override func finalizeAnimatedBoundsChange() {
        layout.finalizeAnimatedBoundsChange()
    }
    
    public override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return layout.initialLayoutAttributesForAppearingItem(at: itemIndexPath)
    }
    
    public override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return layout.finalLayoutAttributesForDisappearingItem(at: itemIndexPath)
    }
    
    public override func initialLayoutAttributesForAppearingSupplementaryElement(ofKind elementKind: String, at elementIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return layout.initialLayoutAttributesForAppearingSupplementaryElement(ofKind: elementKind, at: elementIndexPath)
    }
    
    public override func finalLayoutAttributesForDisappearingSupplementaryElement(ofKind elementKind: String, at elementIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return layout.finalLayoutAttributesForDisappearingSupplementaryElement(ofKind: elementKind, at: elementIndexPath)
    }
    
    public override func initialLayoutAttributesForAppearingDecorationElement(ofKind elementKind: String, at decorationIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return layout.initialLayoutAttributesForAppearingDecorationElement(ofKind: elementKind, at: decorationIndexPath)
    }
    
    public override func finalLayoutAttributesForDisappearingDecorationElement(ofKind elementKind: String, at decorationIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return layout.finalLayoutAttributesForDisappearingDecorationElement(ofKind: elementKind, at: decorationIndexPath)
    }
}
