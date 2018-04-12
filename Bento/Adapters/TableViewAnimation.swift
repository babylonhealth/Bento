import UIKit

public struct TableViewAnimation {
    let sectionInsertion: UITableViewRowAnimation
    let sectionDeletion: UITableViewRowAnimation
    let rowDeletion: UITableViewRowAnimation
    let rowInsertion: UITableViewRowAnimation

    public init(sectionInsertion: UITableViewRowAnimation,
                sectionDeletion: UITableViewRowAnimation,
                rowDeletion: UITableViewRowAnimation,
                rowInsertion: UITableViewRowAnimation) {
        self.sectionInsertion = sectionInsertion
        self.sectionDeletion = sectionDeletion
        self.rowDeletion = rowDeletion
        self.rowInsertion = rowInsertion
    }
}
