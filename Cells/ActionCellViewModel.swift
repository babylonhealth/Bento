import ReactiveSwift
import Result

public struct ActionCellViewModel: Interactable {
    private let style: UIViewStyle<UIButton>
    let visualDependencies: VisualDependenciesProtocol
    let title: String
    let hasDynamicHeight: Bool
    let action: Action<Void, Void, NoError>
    let selectionStyle: UITableViewCellSelectionStyle = .none
    let isInteractable = MutableProperty(true)
    let isLoading: Property<Bool>?

    public init(visualDependencies: VisualDependenciesProtocol,
         style: UIViewStyle<UIButton>,
         title: String,
         hasDynamicHeight: Bool,
         action: Action<Void, Void, NoError>,
         isLoading: Property<Bool>? = nil) {

        self.visualDependencies = visualDependencies
        self.style = style
        self.title = title
        self.hasDynamicHeight = hasDynamicHeight
        self.action = action
        self.isLoading = isLoading
    }

    func applyStyle(to button: UIButton) {
        style.apply(to: button)
        button.setTitle(title, for: .normal)
    }
}
