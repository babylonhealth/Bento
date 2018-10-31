import Foundation

public enum DeleteAction {
    case none
    case action(title: String, callback: () -> Void)

    public var callback: (() -> Void)? {
        switch self {
        case let .action(title: _, callback: callback):
            return callback
        default:
            return nil
        }
    }

    public var title: String? {
        switch self {
        case let .action(title: title, callback: _):
            return title
        default:
            return nil
        }
    }
}
