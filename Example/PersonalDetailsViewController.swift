import UIKit
import Bento
import ReactiveSwift
import ReactiveFeedback
import enum Result.NoError

final class PersonalDetailsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!

    lazy var viewModel = PersonalDetailsViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()

        let renderer = PersonalDetailsRenderer()

        viewModel.state
            .producer
            .map { [weak viewModel] state in
                return renderer.render(state, action: { viewModel?.send($0) })
            }
            .startWithValues(tableView.render)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        tableView.focus(animated: animated)
    }

    private func setupTableView() {
        tableView.estimatedSectionFooterHeight = 18
        tableView.estimatedSectionHeaderHeight = 18
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.sectionFooterHeight = UITableView.automaticDimension
        tableView.keyboardDismissMode = .interactive
    }
}

final class PersonalDetailsViewModel {
    let state: Property<State>
    private let userActionObserver: Signal<UserAction, NoError>.Observer

    init() {
        let (userActions, userActionObserver) = Signal<UserAction, NoError>.pipe()
        self.state = Property(
            initial: State(),
            reduce: PersonalDetailsViewModel.reduce,
            feedbacks: [
                PersonalDetailsViewModel.feedback(userActions)
            ]
        )
        self.userActionObserver = userActionObserver
    }

    func send(_ action: UserAction) {
        userActionObserver.send(value: action)
    }

    struct State {
        var firstName: String = ""
        var lastName: String = ""
        var placeOfBirth: String = ""
        var email: String = ""
        var code: String = ""
        var showMore = false
    }

    enum UserAction {
        case update(StateUpdate)

        struct StateUpdate {
            fileprivate let apply: (inout State) -> Void

            init<U>(_ keyPath: WritableKeyPath<State, U>, _ value: U) {
                apply = { $0[keyPath: keyPath] = value }
            }
        }
    }

    enum Event {
        case ui(UserAction)
    }

    private static func reduce(state: State, event: Event) -> State {
        switch event {
        case let .ui(.update(update)):
            var state = state
            update.apply(&state)
            return state
        }
    }

    private static func feedback(_ userActions: Signal<UserAction, NoError>) -> Feedback<State, Event> {
        return Feedback { scheduler, _ in
            return userActions.map(Event.ui).observe(on: scheduler)
        }
    }
}

struct PersonalDetailsRenderer {
    enum SectionId {
        case details
        case account
    }

    enum NodeId {
        case firstName
        case lastName
        case placeOfBirth
        case email
        case code
        case more
    }

    init() {}

    func render(_ state: PersonalDetailsViewModel.State, action: @escaping (PersonalDetailsViewModel.UserAction) -> Void) -> Box<SectionId, NodeId> {
        return Box.empty
            |-+ Section(id: .details)
            |---+ Node(
                id: .more,
                component: ToggleComponent(
                    isOn: state.showMore,
                    title: "Show Detailed Form",
                    onToggle: { action(.update(.init(\.showMore, $0))) }
                )
            )
            |---+ Node(
                id: .firstName,
                component: TextFieldComponent(
                    title: "First Name",
                    text: state.firstName,
                    didUpdate: { action(.update(.init(\.firstName, $0))) }
                )
            )
            |---+ Node(
                id: .lastName,
                component: TextFieldComponent(
                    title: "Last Name",
                    text: state.lastName,
                    didUpdate: { action(.update(.init(\.lastName, $0))) }
                )
            )
            |---+ Node(
                id: .placeOfBirth,
                component: TextFieldComponent(
                    title: "Place of Birth",
                    text: state.placeOfBirth,
                    didUpdate: { action(.update(.init(\.placeOfBirth, $0))) }
                )
            )
            |-+ Section(id: .account)
            |---? .iff(state.showMore) {
                return [
                    Node(
                        id: .email,
                        component: TextFieldComponent(
                            title: "Email",
                            text: state.email,
                            didUpdate: { action(.update(.init(\.email, $0))) }
                        )
                    ),
                    Node(
                        id: .code,
                        component: TextFieldComponent(
                            title: "Code",
                            text: state.code,
                            didUpdate: { action(.update(.init(\.code, $0))) }
                        )
                    )
                ]
            }
    }
}
