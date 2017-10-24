import ReactiveSwift
import enum Result.NoError

public class ImageOptionsCellViewModel {

    let items: [UIImage]
    let selectionAction: Action<Int, Void, NoError>
    let destructiveAction: Action<Int, Void, NoError>?

    public init(items: [UIImage],
                selectionAction: Action<Int, Void, NoError>,
                destructiveAction: Action<Int, Void, NoError>? = nil) {
        
        self.items = items
        self.selectionAction = selectionAction
        self.destructiveAction = destructiveAction
    }
}
