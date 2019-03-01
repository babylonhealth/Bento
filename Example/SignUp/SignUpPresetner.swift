import Foundation

protocol SignUpPresenterDelegate: class {
    func render(_ state: SignUpPresenter.State)
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
