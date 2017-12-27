import ReactiveSwift
import Result

public final class ActionInputCellViewModel {
    public enum IconStyle {
        case miniature
        case largeRoundAvatar
    }

    private let visualDependencies: VisualDependenciesProtocol
    let icon: SignalProducer<UIImage, NoError>?
    let subIcon: UIImage?
    let iconStyle: IconStyle
    let title: Property<String>
    let input: Property<String>?
    let inputTextAlignment: TextAlignment
    let selectionStyle: UITableViewCellSelectionStyle
    let isSelected: Action<Void, Void, NoError>
    let wasDeleted: Action<Void, Void, NoError>?
    let accessory: UITableViewCellAccessoryType
    let hidesAccessoryWhenDisabled: Bool
    let isVertical: Bool
    private let titleStyle: UIViewStyle<UILabel>?
    private let subtitleStyle: UIViewStyle<UILabel>?

    public init(visualDependencies: VisualDependenciesProtocol,
                icon: SignalProducer<UIImage, NoError>? = nil,
                subIcon: UIImage? = nil,
                iconStyle: IconStyle = .miniature,
                title: Property<String>,
                input: Property<String>? = nil,
                inputTextAlignment: TextAlignment = .leading,
                selected: Action<Void, Void, NoError>,
                deleted: Action<Void, Void, NoError>? = nil,
                accessory: UITableViewCellAccessoryType = .disclosureIndicator,
                hidesAccessoryWhenDisabled: Bool = true,
                titleStyle: UIViewStyle<UILabel>? = nil,
                subtitleStyle: UIViewStyle<UILabel>? = nil,
                selectionStyle: UITableViewCellSelectionStyle = .gray,
                isVertical: Bool = false) {
        self.visualDependencies = visualDependencies
        self.icon = icon
        self.subIcon = subIcon
        self.iconStyle = iconStyle
        self.title = title
        self.inputTextAlignment = inputTextAlignment
        self.input = input
        self.isSelected = selected
        self.wasDeleted = deleted
        self.accessory = accessory
        self.hidesAccessoryWhenDisabled = hidesAccessoryWhenDisabled
        self.titleStyle = titleStyle
        self.subtitleStyle = subtitleStyle
        self.selectionStyle = selectionStyle
        self.isVertical = isVertical
    }

    public convenience init(visualDependencies: VisualDependenciesProtocol,
                            icon: SignalProducer<UIImage, NoError>? = nil,
                            subIcon: UIImage? = nil,
                            title: String,
                            input: Property<String>? = nil,
                            inputTextAlignment: TextAlignment = .leading,
                            selected: Action<Void, Void, NoError>,
                            accessory: UITableViewCellAccessoryType = .disclosureIndicator,
                            hidesAccessoryWhenDisabled: Bool = true,
                            titleStyle: UIViewStyle<UILabel>? = nil,
                            subtitleStyle: UIViewStyle<UILabel>? = nil,
                            isVertical: Bool = false) {
        self.init(visualDependencies: visualDependencies,
                  icon: icon,
                  subIcon: subIcon,
                  title: Property(value: title),
                  input: input,
                  inputTextAlignment: inputTextAlignment,
                  selected: selected,
                  accessory: accessory,
                  hidesAccessoryWhenDisabled: hidesAccessoryWhenDisabled,
                  titleStyle: titleStyle,
                  subtitleStyle: subtitleStyle,
                  isVertical: isVertical)
    }

    func applyTitleStyle(to label: UILabel) {
        if let titleStyle = titleStyle {
            titleStyle.apply(to: label)
        } else {
            visualDependencies.styles.labelFormFieldTitle.apply(to: label)
        }
    }

    func applyInputStyle(to label: UILabel) {
        if let subtitleStyle = subtitleStyle {
            subtitleStyle.apply(to: label)
        } else {
            visualDependencies.styles.labelFormFieldInputValue(alignment: inputTextAlignment).apply(to: label)
        }
    }
}
