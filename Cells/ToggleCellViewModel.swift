import ReactiveSwift

public struct ToggleCellViewModel {

    private let visualDependencies: VisualDependenciesProtocol
    let title: String
    let isOn: MutableProperty<Bool>

    public init(title: String,
         isOn: MutableProperty<Bool>,
         visualDependencies: VisualDependenciesProtocol) {

        self.visualDependencies = visualDependencies
        self.title = title
        self.isOn = isOn
    }

    func applyTitleStyle(to label: UILabel) {
        visualDependencies.styles.labelFormFieldTitle.apply(to: label)
    }
}
