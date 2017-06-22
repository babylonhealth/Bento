import ReactiveSwift
import Result

public struct ActionCellViewSpec {
    public let title: String
    public let buttonStyle: UIViewStyle<UIButton>
    public let hasDynamicHeight: Bool
    public let selectionStyle: UITableViewCellSelectionStyle

    public init(title: String,
                buttonStyle: UIViewStyle<UIButton>,
                hasDynamicHeight: Bool,
                selectionStyle: UITableViewCellSelectionStyle = .none) {
        self.title = title
        self.buttonStyle = buttonStyle
        self.selectionStyle = selectionStyle
        self.hasDynamicHeight = hasDynamicHeight
    }
}

public struct ActionCellViewModel: Interactable {
    public let action: Action<Void, Void, NoError>
    public let isInteractable = MutableProperty(true)
    public let isLoading: Property<Bool>?

    public init(action: Action<Void, Void, NoError>, isLoading: Property<Bool>? = nil) {
        self.action = action
        self.isLoading = isLoading
    }
}
