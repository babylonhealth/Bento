import ReactiveSwift

public final class ToggleCellViewModel {

    private let visualDependencies: VisualDependenciesProtocol

    let title: String
    let isOn: MutableProperty<Bool>
    let icon: UIImage?
    let isEnabled: Property<Bool>

    public init(title: String,
         isOn: MutableProperty<Bool>,
         icon: UIImage? = nil,
         isEnabled: Property<Bool> = Property(value: true),
         visualDependencies: VisualDependenciesProtocol) {

        self.visualDependencies = visualDependencies
        self.title = title
        self.isOn = isOn
        self.icon = icon
        self.isEnabled = isEnabled
    }

    func applyTitleStyle(to label: UILabel) {
        visualDependencies.styles.labelFormFieldTitle.apply(to: label)
    }
}
