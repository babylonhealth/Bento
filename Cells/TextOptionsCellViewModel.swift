import ReactiveSwift
import enum Result.NoError

public class TextOptionsCellViewModel {

    let items: Property<[String]>
    let selectionAction: Action<Void, Void, NoError>
    let destructiveAction: Action<Void, Void, NoError>
    
    public init(items: Property<[String]>, selectionAction: Action<Void, Void, NoError>, destructiveAction: Action<Void, Void, NoError>) {
        
        self.items = items
        self.selectionAction = selectionAction
        self.destructiveAction = destructiveAction
    }
}
