import ReactiveSwift

public struct ToggleCellViewModel {

    private let visualDependencies: VisualDependenciesProtocol
    let title: String
    let isOn: MutableProperty<Bool>
    let isEnabled: Property<Bool>

    public init(title: String,
         isOn: MutableProperty<Bool>,
         isEnabled: Property<Bool> = Property(value: true),
         visualDependencies: VisualDependenciesProtocol) {

        self.visualDependencies = visualDependencies
        self.title = title
        self.isOn = isOn
        self.isEnabled = isEnabled
    }

    func applyTitleStyle(to label: UILabel) {
        visualDependencies.styles.labelFormFieldTitle.apply(to: label)
    }
}
