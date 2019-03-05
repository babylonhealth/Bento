
extension Optional where Wrapped: Collection {
    func isEmpty() -> Bool {
        switch self {
        case .none:
            return true
        case .some(let value):
            return value.isEmpty
        }
    }

    func isNotEmpty() -> Bool {
        return !isEmpty()
    }
}
