import ReactiveSwift
import Result

public final class ActionInputCellViewModel {
    private let visualDependencies: VisualDependenciesProtocol
    let icon: UIImage?
    let title: Property<String>
    let input: Property<String>?
    let inputTextAlignment: TextAlignment
    let selectionStyle: UITableViewCellSelectionStyle = .gray
    let isSelected: Action<Void, Void, NoError>
    let accessory: UITableViewCellAccessoryType

    public init(visualDependencies: VisualDependenciesProtocol,
                icon: UIImage? = nil,
                title: Property<String>,
                input: Property<String>? = nil,
                inputTextAlignment: TextAlignment = .left,
                selected: Action<Void, Void, NoError>,
                accessory: UITableViewCellAccessoryType = .disclosureIndicator) {
        self.visualDependencies = visualDependencies
        self.icon = icon
        self.title = title
        self.inputTextAlignment = inputTextAlignment
        self.input = input
        self.isSelected = selected
        self.accessory = accessory
    }

    public convenience init(visualDependencies: VisualDependenciesProtocol,
                            icon: UIImage? = nil,
                            title: String,
                            input: Property<String>? = nil,
                            inputTextAlignment: TextAlignment = .left,
                            selected: Action<Void, Void, NoError>,
                            accessory: UITableViewCellAccessoryType = .disclosureIndicator) {
        self.init(visualDependencies: visualDependencies,
                  icon: icon,
                  title: Property(value: title),
                  input: input,
                  inputTextAlignment: inputTextAlignment,
                  selected: selected,
                  accessory: accessory)
    }

    func applyTitleStyle(to label: UILabel) {
        visualDependencies.styles.labelFormFieldTitle.apply(to: label)
    }

    func applyInputStyle(to label: UILabel) {
        visualDependencies.styles.labelFormFieldInputValue(alignment: inputTextAlignment).apply(to: label)
    }
}
