import UIKit
import ReactiveSwift
import ReactiveCocoa
import ReactiveFeedback
import Result
import Kingfisher
import FormsKit

final class MoviesListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    private lazy var viewModel = PaginationViewModel()
    private let (retrySignal, retryObserver) = Signal<Void, NoError>.pipe()

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.form.producer.startWithValues(tableView.render)
        viewModel.nearBottomBinding <~ tableView!.rac_nearBottomSignal
        viewModel.retryBinding <~ retrySignal
        viewModel.errors.producer
            .skipNil()
            .startWithValues { [weak self] in
                self?.showAlert(for: $0)
            }
    }

    func showAlert(for error: NSError) {
        let alert = UIAlertController(title: "Error",
                                      message: error.localizedDescription,
                                      preferredStyle: .alert)
        let action = UIAlertAction(title: "Retry", style: .cancel, handler: { _ in
            self.retryObserver.send(value: ())
        })
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}


final class PaginationViewModel {
    private let token = Lifetime.Token()
    private var lifetime: Lifetime {
        return Lifetime(token)
    }
    private let nearBottomObserver: Signal<Void, NoError>.Observer
    private let retryObserver: Signal<Void, NoError>.Observer

    private let stateProperty: Property<State>
    private let renderer = Renderer()
    let errors: Property<NSError?>
    let refreshing: Property<Bool>
    let form: Property<Form<Renderer.SectionId, Int>>

    var nearBottomBinding: BindingTarget<Void> {
        return BindingTarget(lifetime: lifetime) { value in
            self.nearBottomObserver.send(value: value)
        }
    }

    var retryBinding: BindingTarget<Void> {
        return BindingTarget(lifetime: lifetime) { value in
            self.retryObserver.send(value: value)
        }
    }

    init() {
        let (nearBottomSignal, nearBottomObserver) = Signal<Void, NoError>.pipe()
        let (retrySignal, retryObserver) = Signal<Void, NoError>.pipe()
        let feedbacks = [
            Feedbacks.loadNextFeedback(for: nearBottomSignal),
            Feedbacks.pagingFeedback(),
            Feedbacks.retryFeedback(for: retrySignal),
            Feedbacks.retryPagingFeedback()
        ]

        self.stateProperty = Property(initial: State.initial,
                                      reduce: State.reduce,
                                      feedbacks: feedbacks)

        self.form = Property(initial: Form.empty,
                             then: stateProperty.producer
                                 .filterMap { $0.newMovies }
                                 .map(renderer.render))

        self.errors = stateProperty.map { $0.lastError }
        self.refreshing = stateProperty.map { $0.isRefreshing }
        self.nearBottomObserver = nearBottomObserver
        self.retryObserver = retryObserver
    }

    enum Feedbacks {
        static func loadNextFeedback(for nearBottomSignal: Signal<Void, NoError>) -> Feedback<State, Event> {
            return Feedback(predicate: { !$0.paging }) { _ in
                nearBottomSignal
                    .map { Event.startLoadingNextPage }
            }
        }

        static func pagingFeedback() -> Feedback<State, Event> {
            return Feedback<State, Event>(query: { $0.nextPage }) { (nextPage) -> SignalProducer<Event, NoError> in
                URLSession.shared.fetchMovies(page: nextPage)
                    .map(Event.response)
                    .flatMapError { error in
                        SignalProducer(value: Event.failed(error))
                    }.observe(on: UIScheduler())
            }
        }

        static func retryFeedback(for retrySignal: Signal<Void, NoError>) -> Feedback<State, Event> {
            return Feedback<State, Event>(query: { $0.lastError }) { _ -> Signal<Event, NoError> in
                retrySignal.map { Event.retry }
            }
        }

        static func retryPagingFeedback() -> Feedback<State, Event> {
            return Feedback<State, Event>(query: { $0.retryPage }) { (nextPage) -> SignalProducer<Event, NoError> in
                URLSession.shared.fetchMovies(page: nextPage)
                    .map(Event.response)
                    .flatMapError { error in
                        SignalProducer(value: Event.failed(error))
                    }.observe(on: UIScheduler())
            }
        }
    }

    struct Context {
        var batch: Results
        var movies: [Movie]

        static var empty: Context {
            return Context(batch: Results.empty(), movies: [])
        }
    }

    enum State {
        case initial
        case paging(context: Context)
        case loadedPage(context: Context)
        case refreshing(context: Context)
        case refreshed(context: Context)
        case error(error: NSError, context: Context)
        case retry(context: Context)

        var newMovies: [Movie]? {
            switch self {
            case .paging(context:let context):
                return context.movies
            case .loadedPage(context:let context):
                return context.movies
            case .refreshed(context:let context):
                return context.movies
            default:
                return nil
            }
        }

        var context: Context {
            switch self {
            case .initial:
                return Context.empty
            case .paging(context:let context):
                return context
            case .loadedPage(context:let context):
                return context
            case .refreshing(context:let context):
                return context
            case .refreshed(context:let context):
                return context
            case .error(error:_, context:let context):
                return context
            case .retry(context:let context):
                return context
            }
        }

        var movies: [Movie] {
            return context.movies
        }

        var batch: Results {
            return context.batch
        }

        var refreshPage: Int? {
            switch self {
            case .refreshing:
                return nil
            default:
                return 1
            }
        }

        var nextPage: Int? {
            switch self {
            case .paging(context:let context):
                return context.batch.page + 1
            case .refreshed(context:let context):
                return context.batch.page + 1
            default:
                return nil
            }
        }

        var retryPage: Int? {
            switch self {
            case .retry(context:let context):
                return context.batch.page + 1
            default:
                return nil
            }
        }

        var lastError: NSError? {
            switch self {
            case .error(error:let error, context:_):
                return error
            default:
                return nil
            }
        }

        var isRefreshing: Bool {
            switch self {
            case .refreshing:
                return true
            default:
                return false
            }
        }

        var paging: Bool {
            switch self {
            case .paging:
                return true
            default:
                return false
            }
        }

        static func reduce(state: State, event: Event) -> State {
            switch event {
            case .startLoadingNextPage:
                return .paging(context: state.context)
            case .response(let batch):
                var copy = state.context
                copy.batch = batch
                copy.movies += batch.results
                return .loadedPage(context: copy)
            case .failed(let error):
                return .error(error: error, context: state.context)
            case .retry:
                return .retry(context: state.context)
            }
        }
    }

    enum Event {
        case startLoadingNextPage
        case response(Results)
        case failed(NSError)
        case retry
    }

    final class Renderer {
        enum SectionId {
            case noId
        }

        func render(movies: [Movie]) -> Form<SectionId, Int> {
            let rows = movies.map { movie in
                return Node(id: movie.id,
                            component: MovieComponent(movie: movie))
            }
            return Form.empty
                |-+ Section(id: SectionId.noId)
                |--* rows
        }
    }
}

// MARK: - ⚠️ Danger ⚠️ Boilerplate

extension UIScrollView {
    var rac_contentOffset: Signal<CGPoint, NoError> {
        return self.reactive.signal(forKeyPath: "contentOffset")
            .filterMap { change in
                guard let value = change as? NSValue else {
                    return nil
                }
                return value.cgPointValue
            }
    }

    var rac_nearBottomSignal: Signal<Void, NoError> {
        func isNearBottomEdge(scrollView: UIScrollView, edgeOffset: CGFloat = 44.0) -> Bool {
            return scrollView.contentOffset.y + scrollView.frame.size.height + edgeOffset > scrollView.contentSize.height
        }

        return rac_contentOffset
            .filterMap { _ in
            if isNearBottomEdge(scrollView: self) {
                return ()
            }
            return nil
        }
    }
}


// Key for https://www.themoviedb.org API
let apiKey = ""
let correctKey = "d4f0bdb3e246e2cb3555211e765c89e3"

struct Results: Codable {
    let page: Int
    let totalResults: Int
    let totalPages: Int
    let results: [Movie]

    static func empty() -> Results {
        return Results.init(page: 0, totalResults: 0, totalPages: 0, results: [])
    }

    enum CodingKeys: String, CodingKey {
        case page
        case totalResults = "total_results"
        case totalPages = "total_pages"
        case results
    }
}

struct Movie: Codable {
    let id: Int
    let overview: String
    let title: String
    let posterPath: String?

    var posterURL: URL? {
        return posterPath
            .map {
                "https://image.tmdb.org/t/p/w342/\($0)"
            }
            .flatMap(URL.init(string:))
    }

    enum CodingKeys: String, CodingKey {
        case id
        case overview
        case title
        case posterPath = "poster_path"
    }
}

var shouldFail = false

func switchFail() {
    shouldFail = !shouldFail
}

extension URLSession {
    func fetchMovies(page: Int) -> SignalProducer<Results, NSError> {
        return SignalProducer.init({ (observer, lifetime) in
            let url = URL(string: "https://api.themoviedb.org/3/discover/movie?api_key=\(shouldFail ? apiKey : correctKey)&sort_by=popularity.desc&page=\(page)")!
            switchFail()
            let task = self.dataTask(with: url, completionHandler: { (data, response, error) in
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 401 {
                    let error = NSError(domain: "come.reactivefeedback",
                                        code: 401,
                                        userInfo: [NSLocalizedDescriptionKey: "Forced failure to illustrate Retry"])
                    observer.send(error: error)
                } else if let data = data {
                    do {
                        let results = try JSONDecoder().decode(Results.self, from: data)
                        observer.send(value: results)
                    } catch {
                        observer.send(error: error as NSError)
                    }
                } else if let error = error {
                    observer.send(error: error as NSError)
                    observer.sendCompleted()
                } else {
                    observer.sendCompleted()
                }
            })

            lifetime += AnyDisposable(task.cancel)
            task.resume()
        })
    }
}
