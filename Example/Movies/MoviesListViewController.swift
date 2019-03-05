import UIKit
import ReactiveSwift
import ReactiveCocoa
import ReactiveFeedback
import Result
import Kingfisher
import Bento

final class MoviesListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    private lazy var viewModel = PaginationViewModel()
    private let (retrySignal, retryObserver) = Signal<Void, NoError>.pipe()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.sectionHeaderHeight = 0
        tableView.sectionFooterHeight = 0
        viewModel.box.producer.take(first: 1).startWithValues(tableView.render)
        viewModel.box.producer.skip(first: 1).startWithValues { [tableView] in
            tableView?.render($0, animated: false)
        }

        viewModel.nearBottomBinding <~ tableView!.rac_nearBottomSignal
        viewModel.retryBinding <~ retrySignal
    }
}


final class PaginationViewModel {
    private let token = Lifetime.Token()
    private let lifetime: Lifetime
    private let state: Property<State>
    private let renderer = PaginationViewModel.Renderer()

    let box: Property<Box<Renderer.SectionId, Renderer.RowId>>
    let nearBottomBinding: BindingTarget<Void>
    let retryBinding: BindingTarget<Void>

    init() {
        let (nearBottomSignal, nearBottomObserver) = Signal<Void, NoError>.pipe()
        let (retrySignal, retryObserver) = Signal<Void, NoError>.pipe()
        let actionsPipe = Signal<Action, NoError>.pipe()

        let feedbacks = [
            PaginationViewModel.whenPaging(nearBottomSignal: nearBottomSignal),
            PaginationViewModel.pagingFeedback(),
            PaginationViewModel.whenError(retrySignal: retrySignal),
            PaginationViewModel.whenRetry(),
            PaginationViewModel.delete(trigger: actionsPipe.output)
        ]
        self.lifetime = Lifetime(token)
        self.nearBottomBinding = BindingTarget(lifetime: lifetime, action: nearBottomObserver.send)
        self.retryBinding = BindingTarget(lifetime: lifetime, action: retryObserver.send)
        self.state = Property(initial: State.initial,
                              reduce: State.reduce,
                              feedbacks: feedbacks)
        self.box = Property(initial: Box.empty, then: state.producer.filterMap { [renderer] state in
            return renderer.render(state: state, observer: actionsPipe.input.send)
        })
    }

    private static func whenPaging(nearBottomSignal: Signal<Void, NoError>) -> Feedback<State, Event> {
        return Feedback { state -> Signal<Event, NoError> in
            if case .paging = state {
                return .empty
            }
            return nearBottomSignal
                .map { Event.startLoadingNextPage }
        }
    }

    private static func pagingFeedback() -> Feedback<State, Event> {
        return Feedback<State, Event>(skippingRepeated: { $0.nextPage }) { (nextPage) -> SignalProducer<Event, NoError> in
            URLSession.shared.fetchMovies(page: nextPage)
                .map(Event.response)
                .flatMapError { error in
                    SignalProducer(value: Event.failed(error))
                }
        }
    }

    private static func whenError(retrySignal: Signal<Void, NoError>) -> Feedback<State, Event> {
        return Feedback { state -> Signal<Event, NoError> in
            guard case .error = state else { return .empty }
            return retrySignal.map { Event.retry }
        }
    }

    private static func whenRetry() -> Feedback<State, Event> {
        return Feedback { state -> SignalProducer<Event, NoError> in
            guard case .retry(let context) = state else { return .empty }
            return URLSession.shared.fetchMovies(page: context.batch.page + 1)
                .map(Event.response)
                .flatMapError { error in
                    return SignalProducer(value: Event.failed(error))
                }
        }
    }

    private static func delete(trigger: Signal<Action, NoError>) -> Feedback<State, Event> {
        return Feedback { _ -> Signal<Event, NoError> in
            return trigger.map(Event.ui)
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
        case error(error: NSError, context: Context)
        case retry(context: Context)

        var newMovies: [Movie]? {
            switch self {
            case .loadedPage(context:let context):
                return context.movies
            default:
                return nil
            }
        }

        private var context: Context {
            switch self {
            case .initial:
                return Context.empty
            case .paging(context:let context):
                return context
            case .loadedPage(context:let context):
                return context
            case .error(error:_, context:let context):
                return context
            case .retry(context:let context):
                return context
            }
        }

        var nextPage: Int? {
            switch self {
            case .paging(context:let context):
                return context.batch.page + 1
            case .initial:
                return 1
            default:
                return nil
            }
        }

        static func reduce(state: State, event: Event) -> State {
            switch event {
            case .reload:
                return initial
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
            case let .ui(.deleteMovieAtIndex(index)):
                var context = state.context
                context.movies.remove(at: index)
                return .loadedPage(context: context)
            }
        }
    }

    enum Action {
        case deleteMovieAtIndex(Int)
    }

    enum Event {
        case reload
        case startLoadingNextPage
        case response(Results)
        case failed(NSError)
        case retry
        case ui(Action)
    }

    final class Renderer {
        func render(state: State, observer: @escaping (Action) -> Void) -> Box<SectionId, RowId>? {
            switch state {
            case .initial:
                return renderLoading()
            case .loadedPage(let context):
                return render(movies: context.movies, observer: observer)
            default:
                return nil
            }
        }

        private func render(movies: [Movie], observer: @escaping (Action) -> Void) -> Box<SectionId, RowId> {
            let rows = movies.enumerated().map { (index, movie) in
                return RowId.movie(movie) <> MovieComponent(movie: movie, didDelete: {
                    observer(.deleteMovieAtIndex(index))
                })
            }
            return Box.empty
                |-+ Section(id: SectionId.noId)
                |---* rows
        }

        private func renderLoading() -> Box<SectionId, RowId> {
            return Box<SectionId, RowId>.empty
                |-+ Section(id: SectionId.noId)
                |---+ Node(id: RowId.loading, component: LoadingIndicatorComponent(isLoading: true))
        }

        enum SectionId {
            case noId
        }

        enum RowId: Hashable {
            case loading
            case movie(Movie)

            var hashValue: Int {
                switch self {
                case .loading:
                    return -1
                case .movie(let movie):
                    return movie.hashValue
                }
            }

            static func ==(lhs: RowId, rhs: RowId) -> Bool {
                switch (lhs, rhs) {
                case let (.movie(lhsMovie), .movie(rhsMovie)):
                    return lhsMovie == rhsMovie
                case (.loading, .loading):
                    return true
                default:
                    return false
                }
            }
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

struct Movie: Codable, Hashable {
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

    var hashValue: Int {
        return id.hashValue ^ overview.hashValue ^ title.hashValue ^ (posterPath ?? "").hashValue
    }

    static func ==(lhs: Movie, rhs: Movie) -> Bool {
        return lhs.id == rhs.id &&
            lhs.overview == rhs.overview &&
            lhs.title == rhs.title &&
            lhs.posterPath == rhs.posterPath
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
//            switchFail()
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
