import ReactiveSwift
import Result

public final class ActionInputCellViewModel {
    public enum IconStyle {
        case miniature
        case largeRoundAvatar
    }

    private let visualDependencies: VisualDependenciesProtocol
    let icon: UIImage?
    let iconStyle: IconStyle
    let title: Property<String>
    let input: Property<String>?
    let inputTextAlignment: TextAlignment
    let selectionStyle: UITableViewCellSelectionStyle = .gray
    let isSelected: Action<Void, Void, NoError>
    let accessory: UITableViewCellAccessoryType
    private let titleStyle: UIViewStyle<UILabel>?

    public init(visualDependencies: VisualDependenciesProtocol,
                icon: UIImage? = nil,
                iconStyle: IconStyle = .miniature,
                title: Property<String>,
                input: Property<String>? = nil,
                inputTextAlignment: TextAlignment = .left,
                selected: Action<Void, Void, NoError>,
                accessory: UITableViewCellAccessoryType = .disclosureIndicator,
                titleStyle: UIViewStyle<UILabel>? = nil) {
        self.visualDependencies = visualDependencies
        self.icon = icon
        self.iconStyle = iconStyle
        self.title = title
        self.inputTextAlignment = inputTextAlignment
        self.input = input
        self.isSelected = selected
        self.accessory = accessory
        self.titleStyle = titleStyle
    }

    public convenience init(visualDependencies: VisualDependenciesProtocol,
                            icon: UIImage? = nil,
                            title: String,
                            input: Property<String>? = nil,
                            inputTextAlignment: TextAlignment = .left,
                            selected: Action<Void, Void, NoError>,
                            accessory: UITableViewCellAccessoryType = .disclosureIndicator,
                            titleStyle: UIViewStyle<UILabel>? = nil) {
        self.init(visualDependencies: visualDependencies,
                  icon: icon,
                  title: Property(value: title),
                  input: input,
                  inputTextAlignment: inputTextAlignment,
                  selected: selected,
                  accessory: accessory,
                  titleStyle: titleStyle)
    }

    func applyTitleStyle(to label: UILabel) {
        if let titleStyle = titleStyle {
            titleStyle.apply(to: label)
        } else {
            visualDependencies.styles.labelFormFieldTitle.apply(to: label)
        }
    }

    func applyInputStyle(to label: UILabel) {
        visualDependencies.styles.labelFormFieldInputValue(alignment: inputTextAlignment).apply(to: label)
    }
}
