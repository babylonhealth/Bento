import Foundation
import UIKit
import Bento
import BentoKit
import StyleSheets

final class SignUpViewController: UIViewController, SignUpPresenterDelegate, Navigator {
    @IBOutlet weak var tableView: UITableView!
    private let presenter: SignUpPresenter
    private lazy var adapter: BoxTableViewAdapter<SectionID, RowID> = {
        return BoxTableViewAdapter(with: tableView)
    }()

    required init?(coder aDecoder: NSCoder) {
        presenter = SignUpPresenter()
        super.init(coder: aDecoder)
        presenter.delegate = self
        presenter.navigator = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "SignUp"
        tableView.prepareForBoxRendering(with: adapter)
        tableView.tableFooterView = UIView()
        let backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
        tableView.backgroundColor = backgroundColor
        view.backgroundColor = backgroundColor
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.layoutMargins = .zero
        presenter.viewDidAppear()
    }

    func showAlert(title: String, message: String) {
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "Ok", style: .destructive))
        self.present(alertView, animated: true)
    }

    func render(_ state: SignUpPresenter.State) {
        let box = createBox(from: state)
        tableView.render(box)
    }

    private var headersStyleSheet: Component.Description.StyleSheet {
        return Component.Description.StyleSheet(
                text: LabelStyleSheet(
                        font: UIFont.preferredFont(forTextStyle: .headline)
                )
        )
    }

    private var inputStyleSheet: Component.TextInput.StyleSheet {
        return Component.TextInput.StyleSheet()
            .compose(\.backgroundColor, .white)
    }

    private var descriptionStyleSheet: Component.TitledDescription.StyleSheet {
        return Component.TitledDescription.StyleSheet()
            .compose(\.backgroundColor, .white)
    }

    private func createBox(from state: SignUpPresenter.State) -> Box<SectionID, RowID> {
        return Box.empty
               |-+ section(id: .credential, text: "Credential")
               |---+ email()
               |---* passwordComponents(state)
               |-? .iff(state.isSecurityQuestionsSectionVisible) {
                    self.section(id: .securityQuestion, text: "Security question")
                    |---+ self.securityQuestion(state)
                    |---? .iff(state.chosenSecurityQuestion != nil) {
                        self.securityQuestionAnswer(state)
                    }
               }
               |-? .iff(state.isAdditionalInfoSectionVisible) {
                    self.section(id: .info, text: "Additional information")
                    |---+ self.birthday(state)
                }
               |-? .iff(state.isSignUpButtonVisible) {
                    self.section(id: .signUpAction)
                    |---+ self.signUpButton(state)
               }
    }

    private func section(id: SectionID, text: String? = nil) -> Section<SectionID, RowID> {
        guard let text = text else {
            return Section(id: id, footer: Component.EmptySpace(height: 16))
        }

        return Section(
            id: id,
            header: Component.Description(
                text: text,
                styleSheet: headersStyleSheet
            ),
            footer: Component.EmptySpace(
                height: 16
            )
        )
    }

    private func email() -> Node<RowID> {
        return Node(
            id: .email,
            component: Component.TextInput(
                title: "E-mail",
                placeholder: "john@example.com",
                text: nil,
                keyboardType: .emailAddress,
                accessory: .none,
                textWillChange: nil,
                textDidChange: self.presenter.didChangeEmail,
                didTapAccessory: nil,
                styleSheet: inputStyleSheet
            )
        )
    }

    private func passwordComponents(_ state: SignUpPresenter.State) -> [Node<RowID>] {
        let showHideIcon = state.isPasswordRevealed ? #imageLiteral(resourceName: "hide") : #imageLiteral(resourceName: "show")
        return [
            Node(
                id: .password,
                component: Component.TextInput(
                    title: "Password",
                    placeholder: "********",
                    text: TextValue(stringLiteral: state.password ?? ""),
                    isSecureTextEntry: !state.isPasswordRevealed,
                    accessory: .icon(showHideIcon),
                    textDidChange: presenter.didChangePassword,
                    didTapAccessory: presenter.didTogglePasswordVisibility,
                    styleSheet: inputStyleSheet
                )
            ),
            Node(
                id: .confirmPassword,
                component: Component.TextInput(
                    title: "Confirm password",
                    placeholder: "********",
                    text: TextValue(stringLiteral: state.passwordConfirmation ?? ""),
                    isSecureTextEntry: !state.isPasswordRevealed,
                    accessory: .icon(showHideIcon),
                    textDidChange: presenter.didChangePasswordConfirmation,
                    didTapAccessory: presenter.didTogglePasswordVisibility,
                    styleSheet: inputStyleSheet
                )
            )
        ]
    }

    private func birthday(_ state: SignUpPresenter.State) -> Node<RowID> {
        let yearsInSeconds: TimeInterval = 31556952
        let eighteenYearsAgo = Date().addingTimeInterval(-18 * yearsInSeconds)
        let dateFormatter = DateFormatter(format: "dd MMMM yyyy")
        let chosenBirthday = state.chosenBirthday.map(dateFormatter.string) ?? ""
        return RowID.birthday <> Component.TitledDescription(
            texts: [TextValue(stringLiteral: "Birthday")],
            detail: TextValue(stringLiteral: chosenBirthday),
            accessory: .none,
            inputNodes: Component.DatePicker(
                date: state.chosenBirthday ?? eighteenYearsAgo,
                datePickerMode: .date,
                styleSheet: Component.DatePicker.StyleSheet(),
                didPickDate: self.presenter.didChooseBirthday
            ),
            styleSheet: descriptionStyleSheet

        )
    }

    private func securityQuestion(_ state: SignUpPresenter.State) -> Node<RowID> {
        let selected = state.chosenSecurityQuestion ?? "Choose security question..."
        return RowID.secuirtyQuestion <> Component.TitledDescription(
            texts: [TextValue(stringLiteral: selected)],
            accessory: .none,
            inputNodes: Component.OptionPicker(
                options: [
                    "In what city were you born?",
                    "What street did you grow up on?",
                    "What is your favorite movie?"
                ],
                selected: selected,
                didPickItem: self.presenter.didChooseSecurityQuestion,
                styleSheet: Component.OptionPicker.StyleSheet()
            ),
            styleSheet: descriptionStyleSheet

        )
    }

    private func securityQuestionAnswer(_ state: SignUpPresenter.State) -> Node<RowID> {
        return RowID.securityAnswer <> Component.TextInput(
            title: nil,
            placeholder: "Answer",
            text: TextValue(stringLiteral: state.securityQuestionAnswer ?? ""),
            textDidChange: self.presenter.didChangeSecurityAnswer,
            styleSheet: inputStyleSheet
        )
    }

    private func signUpButton(_ state: SignUpPresenter.State) -> Node<RowID> {
        return RowID.signUpButton <> Component.Button(
                title: "Sign Up",
                isEnabled: state.isSignUpButtonEnabled,
                didTap: self.presenter.didPressSignUp,
                styleSheet: Component.Button.StyleSheet(
                        button: ButtonStyleSheet()
                )
        )
    }

    enum SectionID {
        case credential
        case securityQuestion
        case info
        case signUpAction
    }

    enum RowID {
        case email
        case password
        case confirmPassword
        case space
        case birthday
        case gender
        case secuirtyQuestion
        case securityAnswer
        case signUpButton
    }
}


protocol SignUpPresenterDelegate: class {
    func render(_ state: SignUpPresenter.State)
}

protocol Navigator: class {
    func showAlert(title: String, message: String)
}

final class SignUpPresenter {
    weak var delegate: SignUpPresenterDelegate?
    weak var navigator: Navigator?

    var state = State() {
        didSet {
            renderState()
        }
    }

    func viewDidAppear() {
        renderState()
    }

    func didChangeEmail(_ email: String?) {
        state.email = email
    }

    func didChangePassword(_ password: String?) {
        state.password = password
    }

    func didChangePasswordConfirmation(_ password: String?) {
        state.passwordConfirmation = password
    }

    func didTogglePasswordVisibility() {
        state.isPasswordRevealed = !state.isPasswordRevealed
    }

    func didChooseBirthday(_ date: Date) {
        state.chosenBirthday = date
    }

    func didChooseSecurityQuestion(_ question: String?) {
        state.chosenSecurityQuestion = question
    }

    func didChangeSecurityAnswer(_ answer: String?) {
        state.securityQuestionAnswer = answer
    }

    func didPressSignUp() {
        navigator?.showAlert(title: "Did sign up", message: "\(state)")
    }

    private func renderState() {
        delegate?.render(state)
    }

    struct State {
        var email: String? {
            didSet {
                updateSecuritySectionVisibility()
                updateSignUpButtonVisibility()
            }
        }
        var password: String? {
            didSet {
                updateSecuritySectionVisibility()
                updateSignUpButtonVisibility()
            }
        }
        var passwordConfirmation: String? {
            didSet {
                updateSecuritySectionVisibility()
                updateSignUpButtonVisibility()
            }
        }
        var isPasswordRevealed = false
        var isSecurityQuestionsSectionVisible = false
        var chosenSecurityQuestion: String? {
            didSet {
                updateAdditionalSectionVisibility()
                updateSignUpButtonVisibility()
            }
        }
        var securityQuestionAnswer: String? {
            didSet {
                updateAdditionalSectionVisibility()
                updateSignUpButtonVisibility()
            }
        }

        var isSignUpButtonVisible = false
        var isAdditionalInfoSectionVisible = false
        var chosenBirthday: Date? = nil {
            didSet {
                updateSignUpButtonVisibility()
            }
        }


        var isSignUpButtonEnabled: Bool {
            return allFieldsAreFilledIn()
        }

        private mutating func updateSecuritySectionVisibility() {
            guard dontHideIfAlreadyShown(isSecurityQuestionsSectionVisible) else { return }

            isSecurityQuestionsSectionVisible = email.isNotEmpty() &&
                password == passwordConfirmation &&
                password.isNotEmpty()
        }

        private mutating func updateAdditionalSectionVisibility() {
            guard dontHideIfAlreadyShown(isAdditionalInfoSectionVisible) else { return }

            isAdditionalInfoSectionVisible = securityQuestionAnswer.isNotEmpty() &&
                                             chosenSecurityQuestion.isNotEmpty()
        }

        private mutating func updateSignUpButtonVisibility() {
            guard dontHideIfAlreadyShown(isSignUpButtonVisible) else { return }

            isSignUpButtonVisible = allFieldsAreFilledIn()
        }

        private func allFieldsAreFilledIn() -> Bool {
            return securityQuestionAnswer.isNotEmpty() &&
                   chosenSecurityQuestion.isNotEmpty() &&
                   email.isNotEmpty() &&
                   password == passwordConfirmation &&
                   password.isNotEmpty() &&
                   chosenBirthday != nil
        }

        private func dontHideIfAlreadyShown(_ condition: Bool) -> Bool {
            return !condition
        }
    }
}

extension String: BentoKit.Option {
    public var displayName: String { return self }
}

extension Optional where Wrapped == String {
    func isEmpty() -> Bool {
        switch self {
        case .none:
            return true
        case .some(let value):
            return value.isEmpty
        }
    }

    func isNotEmpty() -> Bool {
        return !isEmpty()
    }
}
