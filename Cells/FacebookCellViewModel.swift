import ReactiveSwift
import enum Result.NoError

public struct FacebookCellViewModel: Interactable {
    let selectionStyle: UITableViewCellSelectionStyle = .none
    let title: String = LocalizationUI.SignIn.signInWithFacebook
    let visualDependencies: VisualDependenciesProtocol
    let isInteractable = MutableProperty(true)
    let action: Action<Void, Void, NoError>
    let isLoading: Property<Bool>?

    public init(action: Action<Void, Void, NoError>, visualDependencies: VisualDependenciesProtocol, isLoading: Property<Bool>? = nil) {
        self.action = action
        self.visualDependencies = visualDependencies
        self.isLoading = isLoading
    }

    func applyFacebookButtonStyle(to button: UIButton) {
        visualDependencies.styles.buttonFacebook.apply(to: button)
    }
}
