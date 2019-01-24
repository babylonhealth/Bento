public enum Supplement: Hashable {
    case header
    case footer
    case custom(String)
}

extension Supplement {
    internal var elementKind: String {
        switch self {
        case .header:
            return UICollectionView.elementKindSectionHeader
        case .footer:
            return UICollectionView.elementKindSectionFooter
        case let .custom(kind):
            return kind
        }
    }

    internal init(collectionViewSupplementaryKind kind: String) {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            self = .header
        case UICollectionView.elementKindSectionFooter:
            self = .footer
        default:
            self = .custom(kind)
        }
    }
}
