import UIKit
import FormsKit
import ReactiveSwift
import ReactiveFeedback
import enum Result.NoError

final class BookAppointmentViewController: UIViewController {
    enum SectionId {
        case user
        case consultantDate
        case audioVideo
        case symptoms
        case book
    }

    enum RowId {
        case user
        case consultant
        case date
        case audioVideo
        case symptoms
    }

    @IBOutlet weak var tableView: UITableView!

    lazy var viewModel = BookAppointmentViewModel(renderer: BookAppointmentViewModel.Renderer(patient: Patient(id: "1",
                                                                                                          firstName: "Chuck",
                                                                                                          lastName: "Norris")))

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        self.viewModel.form
            .producer
            .startWithValues(tableView.render)
    }

    private func setupTableView() {
        tableView.estimatedSectionFooterHeight = 18
        tableView.estimatedSectionHeaderHeight = 18
        tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        tableView.sectionFooterHeight = UITableViewAutomaticDimension
    }
}

final class BookAppointmentViewModel {
    private let state: Property<State>
    let form: Property<Form<Renderer.SectionId, Renderer.RowId>>

    init(renderer: Renderer) {
        self.state = Property(initial: State.loading,
                              reduce: BookAppointmentViewModel.reduce,
                              feedbacks: BookAppointmentViewModel.whenLoading())
        self.form = state.map(renderer.render)
    }

    enum State {
        case loading
        case loaded(Appointment)
    }

    enum Event {
        case loaded(Appointment)
    }

    private static func reduce(state: State, event: Event) -> State {
        switch event {
        case let .loaded(appointment):
            return State.loaded(appointment)
        }
    }

    private static func whenLoading() -> Feedback<State, Event> {
        return Feedback(effects: { (state) -> SignalProducer<Event, NoError> in
            guard case .loading = state else { return .empty }
            return SignalProducer
                .timer(interval: .milliseconds(700), on: QueueScheduler.main)
                .map { date in
                    return Event.loaded(Appointment(consultantType: .GP,
                                                    date: date,
                                                    appointmentType: .video))
                }
        })
    }

    final class Renderer {
        private let patient: Patient
        private let dateFormatter = DateFormatter(format: "dd/MM, HH:mm")

        init(patient: Patient) {
            self.patient = patient
        }

        enum SectionId {
            case user
            case consultantDate
            case audioVideo
            case symptoms
            case book
        }

        enum RowId {
            case user
            case consultant
            case date
            case audioVideo
            case symptoms
            case loading
        }

        func render(state: State) -> Form<SectionId, RowId> {
            switch state {
            case .loading:
                return renderLoading()
            case let .loaded(appointment):
                return render(appointment: appointment)
            }
        }

        private func renderLoading() -> Form<SectionId, RowId> {
            return Form<SectionId, RowId>.empty
                |-+ Section(id: SectionId.user,
                            header: EmptySpaceComponent(height: 24, color: .clear))
                |--+ Node(id: RowId.user,
                          component: IconTitleDetailsComponent(icon: #imageLiteral(resourceName:"chuck_norris_walker"),
                                                               title: "\(patient.firstName) \(patient.lastName)",
                            subtitle: ""))
                |-+ Section(id: SectionId.consultantDate,
                            header: EmptySpaceComponent(height: 24, color: .clear))
                |--+ Node(id: RowId.loading, component: LoadingIndicatorComponent(isLoading: true))
        }

        private func render(appointment: Appointment) -> Form<SectionId, RowId> {
            return Form<SectionId, RowId>.empty
                |-+ Section(id: SectionId.user,
                            header: EmptySpaceComponent(height: 24, color: .clear))
                |--+ Node(id: RowId.user,
                          component: IconTitleDetailsComponent(icon: #imageLiteral(resourceName:"chuck_norris_walker"),
                                                               title: "\(patient.firstName) \(patient.lastName)",
                                                               subtitle: ""))
                |-+ Section(id: SectionId.consultantDate,
                            header: EmptySpaceComponent(height: 24, color: .clear))
                |--+ Node(id: RowId.consultant,
                          component: IconTitleDetailsComponent(icon: #imageLiteral(resourceName:"consultantIcon"),
                                                               title: "Consultant type",
                                                               subtitle: render(consultantType: appointment.consultantType)))
                |--+ Node(id: RowId.date,
                          component: IconTitleDetailsComponent(icon: #imageLiteral(resourceName:"timeIcon"),
                                                               title: "Date & time",
                                                               subtitle: dateFormatter.string(from: appointment.date)))
                |-+ Section(id: SectionId.audioVideo,
                            header: EmptySpaceComponent(height: 24, color: .clear))
                |--+ Node(id: RowId.audioVideo,
                          component: SegmetControlComponent(firstIcon: #imageLiteral(resourceName:"video"),
                                                            secondIcon: #imageLiteral(resourceName:"phone"),
                                                            selectedIndex: appointment.appointmentType == .video ? 0 : 1,
                                                            onSegmentSelected: { print("Selected index", $0) }))
                |-+ Section(id: SectionId.audioVideo,
                            header: EmptySpaceComponent(height: 24, color: .clear))
                |-+ Section(id: SectionId.audioVideo,
                            header: ButtonComponent(buttonTitle: "Book",
                                                    onButtonPressed: {
                                                        print("Book an Appointment")
                                                    }))
        }

        private func render(consultantType: ConsultantType) -> String {
            switch consultantType {
            case .GP:
                return "GP"
            case .specialist:
                return "Specialist"
            case .therapist:
                return "Therapist"
            }
        }
    }
}

struct Patient {
    let id: String
    let firstName: String
    let lastName: String
}

struct Appointment {
    let consultantType: ConsultantType
    let date: Date
    let appointmentType: AppointmentType
}

enum ConsultantType {
    case GP
    case specialist
    case therapist
}

enum AppointmentType {
    case video
    case phone
}

extension DateFormatter {
    convenience init(format: String) {
        self.init()
        self.dateFormat = format
    }
}

extension UITableView {
    func render<SectionId, RowId>(form: Form<SectionId, RowId>) {
        form.render(in: self)
    }
}
