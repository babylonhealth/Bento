import ReactiveSwift
import enum Result.NoError

public class TextOptionsCellViewModel {

    let items: Property<[String]>
    let selectionAction: Action<Int, Void, NoError>
    let headline: String?
    
    public init(items: Property<[String]>,
                selectionAction: Action<Int, Void, NoError>,
                headline: String?) {
        self.items = items
        self.selectionAction = selectionAction
        self.headline = headline
    }
}
