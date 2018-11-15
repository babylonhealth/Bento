import Bento
import UIKit

open class BoxLayout<SectioId: Hashable, NodeId: Hashable>: UICollectionViewLayout {
    public var box: Box<SectioId, NodeId> = .empty
    private var _collectionView: UICollectionView?
    
    override open var collectionView: UICollectionView? {
        return super.collectionView ?? _collectionView
    }
    
    public override init() {
        super.init()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(collectionView: UICollectionView?) {
        _collectionView = collectionView
    }
}
