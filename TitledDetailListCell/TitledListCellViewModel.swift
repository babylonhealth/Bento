public struct TitledListItem {
    public let title: String
    public let description: String

    public init(title: String, description: String) {
        self.title = title
        self.description = description
    }
}

public final class TitledListCellViewModel {
    let title: String
    let items: [TitledListItemViewModel]

    init(title: String, items: [TitledListItem]) {
        self.title = title
        self.items = items.map { TitledListItemViewModel(item: $0) }
    }
}
