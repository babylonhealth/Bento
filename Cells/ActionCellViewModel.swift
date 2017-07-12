import ReactiveSwift
import Result

public final class ActionCellViewModel {
    public let action: Action<Void, Void, NoError>
    public let isLoading: Property<Bool>?

    public init(action: Action<Void, Void, NoError>, isLoading: Property<Bool>? = nil) {
        self.action = action
        self.isLoading = isLoading
    }
}
