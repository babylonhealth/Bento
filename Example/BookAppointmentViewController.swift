import UIKit
import Bento
import ReactiveSwift
import ReactiveFeedback
import enum Result.NoError

final class CustomTableViewAdapter<SectionId: Hashable, RowId: Hashable>: TableViewAdapterBase<SectionId, RowId>, UITableViewDataSource, UITableViewDelegate {
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        super.tableView(tableView, willDisplay: cell, forRowAt: indexPath)
        print("Custom Table View Adapter: Will Display Cell at \(indexPath)")
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("Custom Table View Adapter: Cell For Row at \(indexPath)")
        return super.tableView(tableView, cellForRowAt: indexPath)
    }
}

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
        viewModel.box
            .producer
            .startWithValues(tableView.render)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.reload()
    }

    private func setupTableView() {
        tableView.estimatedSectionFooterHeight = 18
        tableView.estimatedSectionHeaderHeight = 18
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.sectionFooterHeight = UITableView.automaticDimension

        let adapter = CustomTableViewAdapter<BookAppointmentViewModel.Renderer.SectionId, BookAppointmentViewModel.Renderer.RowId>(with: tableView)
        tableView.prepareForBoxRendering(with: adapter)
    }
}

final class BookAppointmentViewModel {
    private let state: Property<State>
    private let reloadObserver: Signal<Void, NoError>.Observer
    let box: Property<Box<Renderer.SectionId, Renderer.RowId>>

    init(renderer: Renderer) {
        let (reloadSignal, reloadObserver) = Signal<Void, NoError>.pipe()
        self.state = Property(initial: State.loading,
                              reduce: BookAppointmentViewModel.reduce,
                              feedbacks: [
                                  BookAppointmentViewModel.whenLoading(),
                                  BookAppointmentViewModel.reload(with: reloadSignal)
                              ])
        self.reloadObserver = reloadObserver
        self.box = state.map { return renderer.render(state: $0, onBook: reloadObserver.send(value:)) }
    }

    func reload() {
        reloadObserver.send(value: ())
    }

    enum State {
        case loading
        case loaded(Appointment)
    }

    enum Event {
        case reload
        case loaded(Appointment)
    }

    private static func reduce(state: State, event: Event) -> State {
        switch event {
        case let .loaded(appointment):
            return State.loaded(appointment)
        case .reload:
            return State.loading
        }
    }

    private static func reload(with trigger: Signal<Void, NoError>) -> Feedback<State, Event> {
        return Feedback { _ in
            return trigger.map { Event.reload }
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

        func render(state: State, onBook: @escaping () -> Void) -> Box<SectionId, RowId> {
            switch state {
            case .loading:
                return renderLoading()
            case let .loaded(appointment):
                return render(appointment: appointment, onBook: onBook)
            }
        }

        private func renderLoading() -> Box<SectionId, RowId> {
            return Box<SectionId, RowId>.empty
                |-+ Section(id: SectionId.user,
                            header: EmptySpaceComponent(spec: EmptySpaceComponent.Spec(height: 20, color: .clear)))
                |---+ RowId.user <> IconTitleDetailsComponent(icon: #imageLiteral(resourceName:"chuck_norris_walker"),
                                                               title: "\(patient.firstName) \(patient.lastName)",
                                                               subtitle: "")
                |-+ Section(id: SectionId.consultantDate,
                            header: EmptySpaceComponent(spec: EmptySpaceComponent.Spec(height: 20, color: .clear)))
                |---+ RowId.loading <> LoadingIndicatorComponent(isLoading: true)
        }

        private func render(appointment: Appointment, onBook: @escaping () -> Void) -> Box<SectionId, RowId> {
            return Box<SectionId, RowId>.empty
                |-+ Section(id: SectionId.user,
                            header: EmptySpaceComponent(spec: EmptySpaceComponent.Spec(height: 20, color: .clear)))
                |---+ RowId.user <> IconTitleDetailsComponent(icon: #imageLiteral(resourceName:"chuck_norris_walker"),
                                                               title: "\(patient.firstName) \(patient.lastName)",
                                                               subtitle: "")
                |-+ Section(id: SectionId.consultantDate,
                            header: EmptySpaceComponent(spec: EmptySpaceComponent.Spec(height: 20, color: .clear)))
                |---+ RowId.consultant <> IconTitleDetailsComponent(icon: #imageLiteral(resourceName:"consultantIcon"),
                                                               title: "Consultant type",
                                                               subtitle: render(consultantType: appointment.consultantType))
                |---+ RowId.date <> IconTitleDetailsComponent(icon: #imageLiteral(resourceName: "timeIcon"),
                                                               title: "Date & time",
                                                               subtitle: dateFormatter.string(from: appointment.date))
                |-+ Section(id: SectionId.audioVideo,
                            header: EmptySpaceComponent(spec: EmptySpaceComponent.Spec(height: 20, color: .clear)))
                |---+ RowId.audioVideo <> SegmetControlComponent(firstIcon: #imageLiteral(resourceName:"video"),
                                                            secondIcon: #imageLiteral(resourceName:"phone"),
                                                            selectedIndex: appointment.appointmentType == .video ? 0 : 1,
                                                            onSegmentSelected: { print("Selected index", $0) })
                |-+ Section(id: SectionId.audioVideo,
                            header: EmptySpaceComponent(spec: EmptySpaceComponent.Spec(height: 20, color: .clear)))
                |-+ Section(id: SectionId.audioVideo,
                            header: ButtonComponent(buttonTitle: "Book", onButtonPressed: onBook))
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
