public struct TitledDetailListItem {
    public let title: String
    public let description: String

    public init(title: String, description: String) {
        self.title = title
        self.description = description
    }
}

public final class TitledDetailListCellViewModel {
    private let visualDependencies: VisualDependenciesProtocol
    private let title: String
    let items: [TitledDetailListItemViewModel]

    init(title: String, items: [TitledDetailListItem], visualDependencies: VisualDependenciesProtocol) {
        self.title = title
        self.items = items.map { TitledDetailListItemViewModel(visualDependencies: visualDependencies, item: $0) }
        self.visualDependencies = visualDependencies
    }

    func applyTitleStyle(to label: UILabel) {
        visualDependencies.styles.labelTextTitle3.apply(to: label)
        label.textColor = Colors.black
        label.text = title
    }
}
