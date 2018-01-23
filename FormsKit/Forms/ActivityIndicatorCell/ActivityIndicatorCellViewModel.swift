import ReactiveSwift
import Result

public final class ActivityIndicatorCellViewModel {
    public let isRefreshing: Property<Bool>

    public init(isRefreshing: Property<Bool>) {
        self.isRefreshing = isRefreshing
    }
}
