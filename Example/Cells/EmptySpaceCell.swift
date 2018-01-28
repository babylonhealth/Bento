import UIKit
import FormsKit

final class EmptySpaceCell: UIView {
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
}

final class EmptySpaceComponent: Renderable {
    private let height: CGFloat

    init(height: CGFloat) {
        self.height = height
    }

    func render(in view: EmptySpaceCell) {
        view.heightConstraint.constant = height
        view.backgroundColor = .red
    }
}
