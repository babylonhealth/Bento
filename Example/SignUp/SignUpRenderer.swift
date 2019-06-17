import Bento

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

    private var descriptionStyleSheet: Component.DetailedDescription.StyleSheet {
        return Component.DetailedDescription.StyleSheet()
            .compose(\.backgroundColor, .white)
    }

    func createBox(from state: SignUpPresenter.State) -> Box<SectionID, RowID> {
        return Box.empty
            |-+ section(id: .credential, text: "Credential")
            |---+ email()
            |---* passwordComponents(state)
            |---+ Node(id: .space, component: EmptySpaceComponent(spec: EmptySpaceComponent.Spec(height: 300, color: .clear)))
            |---+ Node(id: .space, component: IconTextComponent(title: "(Scroll down)"))
            |---+ Node(id: .space, component: EmptySpaceComponent(spec: EmptySpaceComponent.Spec(height: 300, color: .clear)))
            |---+ gender(state)
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
        let footer = Component.EmptySpace(height: 16)
        guard let text = text else {
            return Section(id: id, footer: footer)
        }

        return Section(
            id: id,
            header: Component.Description(
                text: text,
                styleSheet: headersStyleSheet
            ),
            footer: footer
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
                    accessory: .icon(showHideIcon),
                    textDidChange: presenter.didChangePassword,
                    didTapAccessory: presenter.didTogglePasswordVisibility,
                    styleSheet: inputStyleSheet
                        .compose(\.text.isSecureTextEntry, !state.isPasswordRevealed)
                )
            ),
            Node(
                id: .confirmPassword,
                component: Component.TextInput(
                    title: "Confirm password",
                    placeholder: "********",
                    text: TextValue(stringLiteral: state.passwordConfirmation ?? ""),
                    accessory: .icon(showHideIcon),
                    textDidChange: presenter.didChangePasswordConfirmation,
                    didTapAccessory: presenter.didTogglePasswordVisibility,
                    styleSheet: inputStyleSheet
                        .compose(\.text.isSecureTextEntry, !state.isPasswordRevealed)
                )
            )
        ]
    }

    private func gender(_ state: SignUpPresenter.State) -> Node<RowID> {
        return Node(id: .gender, component:
            Component.DetailedDescription(
                texts: [.plain("Gender")],
                detail: .plain(state.gender ?? "Choose"),
                accessory: {
                    switch state.pickerState {
                    case .idle:
                        return .chevron
                    case .loading:
                        return .activityIndicator
                    case .showingPicker:
                        return .none
                    }
                }(),
                didTap: { [presenter] in
                    presenter.didTapGender()
                },
                interactionBehavior: [],
                styleSheet: descriptionStyleSheet
            ).autodisplayingCustomInput(
                state.pickerState.showingPicker.map { genders in
                    Component.OptionPicker(
                        options: genders,
                        selected: state.gender.map(Gender.init(displayName:)),
                        didPickItem: {
                            self.presenter.didChangeGender(to: $0.displayName)
                        }
                    )
                }
            )
        )
    }

    private static let dateFormatter = DateFormatter(format: "dd MMMM yyyy")
    private func birthday(_ state: SignUpPresenter.State) -> Node<RowID> {
        let yearsInSeconds: TimeInterval = 31556952
        let eighteenYearsAgo = Date().addingTimeInterval(-18 * yearsInSeconds)
        let chosenBirthday = state.chosenBirthday.map(SignUpRenderer.dateFormatter.string) ?? ""
        return Node(
            id: RowID.birthday,
            component: Component.DetailedDescription(
                texts: [TextValue(stringLiteral: "Birthday")],
                detail: TextValue(stringLiteral: chosenBirthday),
                accessory: .none,
                styleSheet: descriptionStyleSheet
            ).customInput(
                Component.DatePicker(
                    date: state.chosenBirthday ?? eighteenYearsAgo,
                    datePickerMode: .date,
                    styleSheet: Component.DatePicker.StyleSheet(),
                    didPickDate: self.presenter.didChooseBirthday
                )
            )
        )
    }

    private func securityQuestion(_ state: SignUpPresenter.State) -> Node<RowID> {
        let selected = state.chosenSecurityQuestion ?? "Choose security question..."
        return Node(
            id: RowID.securityQuestion,
            component: Component.DetailedDescription(
                texts: [TextValue(stringLiteral: selected)],
                accessory: .none,
                styleSheet: descriptionStyleSheet
            ).customInput(
                Component.OptionPicker(
                    options: [
                        "In what city were you born?",
                        "What street did you grow up on?",
                        "What is your favorite movie?"
                    ],
                    selected: selected,
                    didPickItem: self.presenter.didChooseSecurityQuestion,
                    styleSheet: Component.OptionPicker.StyleSheet()
                )
            )
        )
    }

    private func securityQuestionAnswer(_ state: SignUpPresenter.State) -> Node<RowID> {
        return Node(
            id: RowID.securityAnswer,
            component: Component.TextInput(
                title: nil,
                placeholder: "Answer",
                text: TextValue(stringLiteral: state.securityQuestionAnswer ?? ""),
                textDidChange: self.presenter.didChangeSecurityAnswer,
                styleSheet: inputStyleSheet
            )
        )
    }

    private func signUpButton(_ state: SignUpPresenter.State) -> Node<RowID> {
        return Node(
            id: RowID.signUpButton,
            component: Component.Button(
                title: "Sign Up",
                isEnabled: state.isSignUpButtonEnabled,
                didTap: self.presenter.didPressSignUp,
                styleSheet: Component.Button.StyleSheet(
                    button: ButtonStyleSheet()
                )
            )
        )
    }

    enum SectionID {
        case credential
        case securityQuestion
        case info
        case signUpAction
        case space
    }

    enum RowID {
        case email
        case password
        case confirmPassword
        case space
        case birthday
        case gender
        case securityQuestion
        case securityAnswer
        case signUpButton
    }
}

extension DateFormatter {
    convenience init(format: String) {
        self.init()
        self.dateFormat = format
    }
}

struct Gender: Bento.Option {
    let displayName: String

    static var allGenders: [Gender] = [
        Gender(displayName: "Male"),
        Gender(displayName: "Female"),
        Gender(displayName: "Unspecified")
    ]
}
