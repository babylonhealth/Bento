import ReactiveSwift
import enum Result.NoError

struct FacebookCellViewModel: Interactable {
    let selectionStyle: UITableViewCellSelectionStyle = .none
    let title: String = LocalizationOctopus.SignIn.signInWithFacebook
    let visualDependencies: VisualDependenciesProtocol
    let isInteractable = MutableProperty(true)
    let action: Action<Void, Void, NoError>
    let isLoading: Property<Bool>?

    init(action: Action<Void, Void, NoError>, visualDependencies: VisualDependenciesProtocol, isLoading: Property<Bool>? = nil) {
        self.action = action
        self.visualDependencies = visualDependencies
        self.isLoading = isLoading
    }

    func applyFacebookButtonStyle(to button: UIButton) {
        visualDependencies.styles.buttonFacebook.apply(to: button)
    }
}
