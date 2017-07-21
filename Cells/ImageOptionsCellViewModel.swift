import ReactiveSwift
import enum Result.NoError

public class ImageOptionsCellViewModel {

    let items: Property<[UIImage]>
    let selectionAction: Action<Void, Void, NoError>
    let destructiveAction: Action<Void, Void, NoError>
    
    public init(items: Property<[UIImage]>, selectionAction: Action<Void, Void, NoError>, destructiveAction: Action<Void, Void, NoError>) {
        
        self.items = items
        self.selectionAction = selectionAction
        self.destructiveAction = destructiveAction
    }
}
