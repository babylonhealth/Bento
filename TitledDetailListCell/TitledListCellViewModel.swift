public struct TitledListItem {
    public let title: String
    public let description: String

    public init(title: String, description: String) {
        self.title = title
        self.description = description
    }
}

public final class TitledListCellViewModel {
    private let visualDependencies: VisualDependenciesProtocol
    private let title: String
    let items: [TitledListItemViewModel]

    init(title: String, items: [TitledListItem], visualDependencies: VisualDependenciesProtocol) {
        self.title = title
        self.items = items.map { TitledListItemViewModel(visualDependencies: visualDependencies, item: $0) }
        self.visualDependencies = visualDependencies
    }

    func applyTitleStyle(to label: UILabel) {
        visualDependencies.styles.labelTextTitle3.apply(to: label)
        label.textColor = Colors.black
        label.text = title
    }
}
