import UIKit
import ReactiveSwift
import Result
import Bento

public struct FoodItem: Hashable {
    let image: UIImage
    let title: String
    let body: String
}

struct FoodListViewModel {
    let state: SignalProducer<State, NoError>

    enum State {
        case loading
        case loaded([FoodItem])
    }

    init(content: [FoodItem]) {
        state = SignalProducer.timer(interval: DispatchTimeInterval.seconds(1), on: QueueScheduler.main)
            .map { tick -> [FoodItem] in
                return content.shuffled()
            }
            .map(State.loaded)
            .prefix(value: .loading)
    }
}

extension Array {
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }

        for (firstUnshuffled, unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            let d: Int = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            let i = index(firstUnshuffled, offsetBy: d)
            swapAt(firstUnshuffled, i)
        }
    }

    func shuffled() -> [Element] {
        var result = Array(self)
        result.shuffle()
        return result
    }
}
