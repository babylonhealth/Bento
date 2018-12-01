import Bento
import BentoKit
import Kingfisher
import ReactiveCocoa
import ReactiveFeedback
import ReactiveSwift
import Result
import UIKit
import BentoKit

final class MoviesListViewController: UIViewController {
    @IBOutlet var collectionView: UICollectionView!
    private lazy var viewModel = MoviesViewModel()
    private lazy var renderer = MoviesRenderer()
    private lazy var adapter = BoxCollectionViewLayoutProxy<MoviesRenderer.SectionId, MoviesRenderer.RowId>()
    private let (retrySignal, retryObserver) = Signal<Void, NoError>.pipe()

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.alwaysBounceVertical = true
        collectionView.render(Box<MoviesRenderer.SectionId, MoviesRenderer.RowId>.empty)
        collectionView.collectionViewLayout = adapter
        viewModel.state.producer
            .map { [renderer] in
                renderer.render(state: $0) { _ in }
            }
            .startWithValues(render)

        viewModel.nearBottomBinding <~ collectionView.rac_nearBottomSignal
        viewModel.retryBinding <~ retrySignal
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.send(action: .reload)
    }

    private func render(content: MoviesRenderer.Content) {
        adapter.render(box: content.box, layout: content.layout)
    }

    func showAlert(for error: NSError) {
        let alert = UIAlertController(title: "Error",
                                      message: error.localizedDescription,
                                      preferredStyle: .alert)
        let action = UIAlertAction(title: "Retry", style: .cancel) { _ in
            self.retryObserver.send(value: ())
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}

final class MoviesViewModel {
    private let token: Lifetime.Token
    private let lifetime: Lifetime
    private let actionsPipe = Signal<Action, NoError>.pipe()
    let state: Property<State>
    let nearBottomBinding: BindingTarget<Void>
    let retryBinding: BindingTarget<Void>

    init() {
        let (nearBottomSignal, nearBottomObserver) = Signal<Void, NoError>.pipe()
        let (retrySignal, retryObserver) = Signal<Void, NoError>.pipe()

        let feedbacks = [
            MoviesViewModel.input(trigger: actionsPipe.output),
            MoviesViewModel.whenPaging(nearBottomSignal: nearBottomSignal),
            MoviesViewModel.pagingFeedback(),
            MoviesViewModel.whenError(retrySignal: retrySignal),
            MoviesViewModel.whenRetry(),
        ]
        (lifetime, token) = Lifetime.make()
        nearBottomBinding = BindingTarget(lifetime: lifetime, action: nearBottomObserver.send)
        retryBinding = BindingTarget(lifetime: lifetime, action: retryObserver.send)
        state = Property(initial: State.initial(Context.empty),
                         reduce: State.reduce,
                         feedbacks: feedbacks)
    }

    func send(action: Action) {
        actionsPipe.input.send(value: action)
    }

    private static func input(trigger: Signal<Action, NoError>) -> Feedback<State, Event> {
        return Feedback { _ -> Signal<Event, NoError> in
            trigger.map(Event.ui).observe(on: QueueScheduler.main)
        }
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
                .delay(3, on: QueueScheduler.main)
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
                    SignalProducer(value: Event.failed(error))
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
        case initial(Context)
        case reloading(Context)
        case paging(Context)
        case loadedPage(Context)
        case error(error: NSError, context: Context)
        case retry(Context)

        var context: Context {
            switch self {
            case .initial(let context),
                 .error(error: _, context: let context),
                 .loadedPage(let context),
                 .paging(let context),
                 .reloading(let context),
                 .retry(let context):
                return context
            }
        }

        var newMovies: [Movie]? {
            switch self {
            case .loadedPage(context: let context):
                return context.movies
            default:
                return nil
            }
        }

        var nextPage: Int? {
            switch self {
            case .paging(context: let context):
                return context.batch.page + 1
            case .reloading:
                return 1
            default:
                return nil
            }
        }

        static func reduce(state: State, event: Event) -> State {
            switch event {
            case .startLoadingNextPage:
                return .paging(state.context)
            case .response(let batch):
                var copy = state.context
                copy.batch = batch
                copy.movies += Array(batch.results.dropFirst(13))
                return .loadedPage(copy)
            case .failed(let error):
                return .error(error: error, context: state.context)
            case .retry:
                return .retry(state.context)
            case .ui(.deleteMovieAtIndex(let index)):
                var context = state.context
                context.movies.remove(at: index)
                return .loadedPage(context)
            case .ui(.reload):
                return .reloading(Context.empty)
            }
        }
    }

    enum Action {
        case reload
        case deleteMovieAtIndex(Int)
    }

    enum Event {
        case startLoadingNextPage
        case response(Results)
        case failed(NSError)
        case retry
        case ui(Action)
    }
}

final class MoviesRenderer {
    private let centerYLayout = CenterYLayout<SectionId, RowId>()
    private let listLayout = ListCollectionViewLayout<SectionId, RowId>()

    func render(state: MoviesViewModel.State, observer: @escaping (MoviesViewModel.Action) -> Void) -> Content {
        if state.context.movies.isEmpty {
            return Content(box: renderLoading(),
                           layout: centerYLayout)
        }
        return Content(box: render(movies: state.context.movies, observer: observer),
                       layout: listLayout)
    }

    private func render(movies: [Movie], observer: @escaping (MoviesViewModel.Action) -> Void) -> Box<SectionId, RowId> {
        let rows = movies.enumerated().map { index, movie in
            return RowId.movie(movie) <> MovieComponent(movie: movie) {
                observer(.deleteMovieAtIndex(index))
            }
        }
        return Box.empty
            |-+ Section(id: SectionId.noId)
            |---+ Node(id: .textInput,
                       component: TextFieldComponent(title: "Title", text: "text", didUpdate: { _ in }))
            |---* rows
    }

    private func renderLoading() -> Box<SectionId, RowId> {
        return Box<SectionId, RowId>.empty
            |-+ Section(id: SectionId.noId)
            |---+ Node(id: RowId.loading, component: LoadingIndicatorComponent(isLoading: true))
    }

    struct Content {
        let box: Box<SectionId, RowId>
        let layout: BoxLayout<SectionId, RowId>
    }

    enum SectionId {
        case noId
    }

    enum RowId: Hashable {
        case loading
        case movie(Movie)
        case textInput

        static func ==(lhs: RowId, rhs: RowId) -> Bool {
            switch (lhs, rhs) {
            case (.movie(let lhsMovie), .movie(let rhsMovie)):
                return lhsMovie == rhsMovie
            case (.loading, .loading):
                return true
            default:
                return false
            }
        }
    }
}

// MARK: - ⚠️ Danger ⚠️ Boilerplate

extension UIScrollView {
    var rac_contentOffset: Signal<CGPoint, NoError> {
        return reactive.signal(forKeyPath: "contentOffset")
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
        return Results(page: 0, totalResults: 0, totalPages: 0, results: [])
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
        return SignalProducer.init { observer, lifetime in
            let url = URL(string: "https://api.themoviedb.org/3/discover/movie?api_key=\(shouldFail ? apiKey : correctKey)&sort_by=popularity.desc&page=\(page)")!
//            switchFail()
            let task = self.dataTask(with: url) { data, response, error in
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
            }

            lifetime += AnyDisposable(task.cancel)
            task.resume()
        }
    }
}

