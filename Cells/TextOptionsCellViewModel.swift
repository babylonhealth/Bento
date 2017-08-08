import ReactiveSwift
import enum Result.NoError

public class TextOptionsCellViewModel {

    let items: Property<[String]>
    let selectionAction: Action<Int, Void, NoError>
    
    public init(items: Property<[String]>, selectionAction: Action<Int, Void, NoError>) {
        self.items = items
        self.selectionAction = selectionAction
    }
}
