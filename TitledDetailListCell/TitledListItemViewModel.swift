struct TitledListItemViewModel {
    let title: String
    let description: String

    init(item: TitledListItem) {
        self.title = item.title
        self.description = item.description
    }
}
