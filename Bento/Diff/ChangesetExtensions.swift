import FlexibleDiff

extension Changeset {
    /// Retrieve the positions of all mutated items, in place or moved. The changes are filtered
    /// by the specified collection of pre-removal visible item indices.
    ///
    /// - parameters:
    ///   - visibleItems: The pre-removal indices of the visible items.
    func positionsOfMutations<Indices: Collection>(amongVisible visibleItems: Indices) -> FlattenCollection<[[(source: Int, destination: Int)]]> where Indices.Element == Int {
        return [
            mutations.lazy
                .filter(visibleItems.contains)
                .map { (source: $0, destination: $0) },
            moves.lazy
                .filter { visibleItems.contains($0.source) }
                .map { (source: $0.source, destination: $0.destination) }
        ].joined()
    }
}
