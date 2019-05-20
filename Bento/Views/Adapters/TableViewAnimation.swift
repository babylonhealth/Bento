import UIKit

public struct TableViewAnimation {
    let sectionInsertion: UITableView.RowAnimation
    let sectionDeletion: UITableView.RowAnimation
    let rowDeletion: UITableView.RowAnimation
    let rowInsertion: UITableView.RowAnimation

    public init(sectionInsertion: UITableView.RowAnimation = .fade,
                sectionDeletion: UITableView.RowAnimation = .fade,
                rowDeletion: UITableView.RowAnimation = .fade,
                rowInsertion: UITableView.RowAnimation = .fade) {
        self.sectionInsertion = sectionInsertion
        self.sectionDeletion = sectionDeletion
        self.rowDeletion = rowDeletion
        self.rowInsertion = rowInsertion
    }
}
