import Bento
import BentoKit
import StyleSheets

final class SignUpRenderer {
    private let presenter: SignUpPresenter

    init(presenter: SignUpPresenter) {
        self.presenter = presenter
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

    func createBox(from state: SignUpPresenter.State) -> Box<SectionID, RowID> {
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

    private static let dateFormatter = DateFormatter(format: "dd MMMM yyyy")
    private func birthday(_ state: SignUpPresenter.State) -> Node<RowID> {
        let yearsInSeconds: TimeInterval = 31556952
        let eighteenYearsAgo = Date().addingTimeInterval(-18 * yearsInSeconds)
        let chosenBirthday = state.chosenBirthday.map(SignUpRenderer.dateFormatter.string) ?? ""
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
