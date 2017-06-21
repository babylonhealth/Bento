import Foundation
import UIKit

final class FormTableViewDelegate: NSObject {
}

extension FormTableViewDelegate: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // NOTE: [David] This cannot removed otherwise we are going to introduce a side-effect in `ActionInputCell` 
        // which is triggering the relevant action when the cell is selected. We don't want that selection both visually 
        // as in terms of logic since when the cell is being reused it will receive a call for `setSelected(_:animated:)` 
        // with a true value which will wrongly lead to invocation of the action.
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
