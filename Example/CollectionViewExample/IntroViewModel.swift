import UIKit
import ReactiveSwift
import Result
import Bento

public struct IntroContent {
    let image: UIImage
    let title: String
    let body: String
}

struct IntroViewModel {

    private let state: Property<State>
    //private let reloadObserver: Signal<Void, NoError>.Observer
    let box: Property<Box<IntroRenderer.SectionId, IntroRenderer.RowId>>

    enum State {
        case loading
        case loaded(IntroContent)
    }

    init(_ renderer: IntroRenderer) {
        state = Property(value: State.loading)
        box = state.map { renderer.render(state: $0) }
    }
}
