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
    let selectionStyle: UITableViewCellSelectionStyle = .gray
    let isSelected: Action<Void, Void, NoError>
    let accessory: UITableViewCellAccessoryType
    let isVertical: Bool
    private let titleStyle: UIViewStyle<UILabel>?
    private let subtitleStyle: UIViewStyle<UILabel>?

    public init(visualDependencies: VisualDependenciesProtocol,
                icon: SignalProducer<UIImage, NoError>? = nil,
                subIcon: UIImage? = nil,
                iconStyle: IconStyle = .miniature,
                title: Property<String>,
                input: Property<String>? = nil,
                inputTextAlignment: TextAlignment = .left,
                selected: Action<Void, Void, NoError>,
                accessory: UITableViewCellAccessoryType = .disclosureIndicator,
                titleStyle: UIViewStyle<UILabel>? = nil,
                subtitleStyle: UIViewStyle<UILabel>? = nil,
                isVertical: Bool = false) {
        self.visualDependencies = visualDependencies
        self.icon = icon
        self.subIcon = subIcon
        self.iconStyle = iconStyle
        self.title = title
        self.inputTextAlignment = inputTextAlignment
        self.input = input
        self.isSelected = selected
        self.accessory = accessory
        self.titleStyle = titleStyle
        self.subtitleStyle = subtitleStyle
        self.isVertical = isVertical
    }

    public convenience init(visualDependencies: VisualDependenciesProtocol,
                            icon: SignalProducer<UIImage, NoError>? = nil,
                            subIcon: UIImage? = nil,
                            title: String,
                            input: Property<String>? = nil,
                            inputTextAlignment: TextAlignment = .left,
                            selected: Action<Void, Void, NoError>,
                            accessory: UITableViewCellAccessoryType = .disclosureIndicator,
                            titleStyle: UIViewStyle<UILabel>? = nil,
                            subtitleStyle: UIViewStyle<UILabel>? = nil) {
        self.init(visualDependencies: visualDependencies,
                  icon: icon,
                  subIcon: subIcon,
                  title: Property(value: title),
                  input: input,
                  inputTextAlignment: inputTextAlignment,
                  selected: selected,
                  accessory: accessory,
                  titleStyle: titleStyle,
                  subtitleStyle: subtitleStyle)
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
