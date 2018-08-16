import UIKit

public protocol Deletable {
    var canBeDeleted: Bool { get }
    var deleteActionText: String { get }
    var backgroundColor: UIColor? { get }

    func delete()
}

public extension Deletable {
    var backgroundColor: UIColor? {
        return nil
    }
}
