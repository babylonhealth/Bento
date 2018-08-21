import FlexibleDiff

extension Changeset {
    var mutationIndexPairs: FlattenCollection<[[(source: Int, destination: Int)]]> {
        return [
            mutations.map { ($0, $0) },
            moves.compactMap { $0.isMutated ? ($0.source, $0.destination) : nil }
        ].joined()
    }
}
