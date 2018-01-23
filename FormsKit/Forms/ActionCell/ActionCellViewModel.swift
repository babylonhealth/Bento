import ReactiveSwift
import Result

public final class ActionCellViewModel {
    public let action: Action<Void, Void, NoError>
    public let isLoading: Property<Bool>?
    public let margins: CGFloat?

    public init(action: Action<Void, Void, NoError>,
                isLoading: Property<Bool>? = nil,
                margins: CGFloat? = nil) {
        self.action = action
        self.isLoading = isLoading
        self.margins = margins
    }
}
