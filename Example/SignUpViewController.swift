import Foundation
import UIKit
import Bento
import BentoKit

final class SignUpViewController: UIViewController, SignUpPresenterDelegate {
    @IBOutlet weak var tableView: UITableView!
    private let presenter: SignUpPresenter
    required init?(coder aDecoder: NSCoder) {
        presenter = SignUpPresenter()
        super.init(coder: aDecoder)
        presenter.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.viewWillAppear()
    }

    func render(_ state: SignUpPresenter.State) {
        let box = createBox(from: state)
        tableView.render(box)
    }

    private func createBox(from state: SignUpPresenter.State) -> Box<SectionID, RowID> {
        return Box.empty
            |-+ Section(id: .first)
            |---+ emailComponent()
            |---* passwordComponents(state)
    }

    private func emailComponent() -> Node<RowID> {
        return Node(
            id: .email,
            component: Component.TextInput(
                title: "E-mail",
                placeholder: "john@example.com",
                text: nil,
                keyboardType: .emailAddress,
                accessory: .none,
                textWillChange: nil,
                textDidChange: nil,
                didTapAccessory: nil,
                styleSheet: Component.TextInput.StyleSheet()
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
                    text: nil,
                    isSecureTextEntry: !state.isPasswordRevealed,
                    accessory: .icon(showHideIcon),
                    textDidChange: nil,
                    didTapAccessory: { self.presenter.didTogglePasswordVisibility() },
                    styleSheet: Component.TextInput.StyleSheet()
                )
            ),
            Node(
                id: .confirmPassword,
                component: Component.TextInput(
                    title: "Confirm password",
                    placeholder: "********",
                    text: nil,
                    isSecureTextEntry: !state.isPasswordRevealed,
                    accessory: .icon(showHideIcon),
                    textDidChange: nil,
                    didTapAccessory: { self.presenter.didTogglePasswordVisibility() },
                    styleSheet: Component.TextInput.StyleSheet()
                )
            )
        ]
    }

    enum SectionID {
        case first
    }

    enum RowID {
        case email
        case password
        case confirmPassword
    }
}


protocol SignUpPresenterDelegate: class {
    func render(_ state: SignUpPresenter.State)
}

final class SignUpPresenter {
    weak var delegate: SignUpPresenterDelegate?
    var state = State()

    func viewWillAppear() {
        renderState()
    }

    func didTogglePasswordVisibility() {
        state.isPasswordRevealed = !state.isPasswordRevealed
        renderState()
    }

    private func renderState() {
        delegate?.render(state)
    }

    struct State {
        var isPasswordRevealed = false
    }
}
