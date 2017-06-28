import ReactiveSwift
import Result

public struct ActionInputCellViewModel: Selectable {
    private let visualDependencies: VisualDependenciesProtocol
    let title: String
    let input: Property<String>
    let inputTextAlignment: TextAlignment
    let selectionStyle: UITableViewCellSelectionStyle = .gray
    let isSelected: Action<Void, Void, NoError>
    let accessory: UITableViewCellAccessoryType

    public init(visualDependencies: VisualDependenciesProtocol,
         title: String,
         input: Property<String>,
         inputTextAlignment: TextAlignment = .right,
         selected: Action<Void, Void, NoError>,
         accessory: UITableViewCellAccessoryType = .disclosureIndicator) {
        self.visualDependencies = visualDependencies
        self.title = title
        self.inputTextAlignment = inputTextAlignment
        self.input = input
        self.isSelected = selected
        self.accessory = accessory
    }

    func applyTitleStyle(to label: UILabel) {
        visualDependencies.styles.labelFormFieldTitle.apply(to: label)
    }

    func applyInputStyle(to label: UILabel) {
        visualDependencies.styles.labelFormFieldInputValue(alignment: inputTextAlignment).apply(to: label)
    }
}
