import ReactiveSwift
import enum Result.NoError

public final class FacebookCellViewModel {
    let selectionStyle: UITableViewCellSelectionStyle = .none
    let title: String = LocalizationUI.SignIn.signInWithFacebook
    let visualDependencies: VisualDependenciesProtocol
    let action: Action<Void, Void, NoError>
    let isEnabled: Property<Bool>
    let isLoading: Property<Bool>?

    public init(action: Action<Void, Void, NoError>, isEnabled: Property<Bool> = Property(value: true), visualDependencies: VisualDependenciesProtocol, isLoading: Property<Bool>? = nil) {
        self.action = action
        self.visualDependencies = visualDependencies
        self.isLoading = isLoading
        self.isEnabled = isEnabled
    }

    func applyFacebookButtonStyle(to button: UIButton) {
        visualDependencies.styles.buttonFacebook.apply(to: button)
    }
}
