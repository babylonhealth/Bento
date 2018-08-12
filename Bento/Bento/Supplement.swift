public enum Supplement: Hashable {
    case header
    case footer
    case custom(String)
}

extension Supplement {
    internal var elementKind: String {
        switch self {
        case .header:
            return UICollectionElementKindSectionHeader
        case .footer:
            return UICollectionElementKindSectionFooter
        case let .custom(kind):
            return kind
        }
    }

    internal init(collectionViewSupplementaryKind kind: String) {
        switch kind {
        case UICollectionElementKindSectionHeader:
            self = .header
        case UICollectionElementKindSectionFooter:
            self = .footer
        default:
            self = .custom(kind)
        }
    }
}
