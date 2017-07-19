import ReactiveSwift
import enum Result.NoError

public final class SegmentedCellViewModel {

    public struct Option {
        let title: String
        let icon: UIImage

        public init(title: String, icon: UIImage) {
            self.title = title
            self.icon = icon
        }
    }

    let visualDependencies: VisualDependenciesProtocol

    let options: [Option]
    let isEnabled: Property<Bool>
    let selection: MutableProperty<Int>

    public init(options: [Option], selection: MutableProperty<Int>, isEnabled: Property<Bool>? = nil, visualDependencies: VisualDependenciesProtocol) {
        precondition(!options.isEmpty)
        precondition(options.indices.contains(selection.value))

        self.options = options
        self.selection = selection
        self.isEnabled = isEnabled ?? Property(value: true)
        self.visualDependencies = visualDependencies
    }
}
