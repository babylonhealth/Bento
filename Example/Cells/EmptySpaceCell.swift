import UIKit
import FormsKit

final class EmptySpaceCell: UIView {
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
}

final class EmptySpaceComponent: Renderable {
    private let height: CGFloat
    private let color: UIColor

    init(height: CGFloat, color: UIColor) {
        self.height = height
        self.color = color
    }

    func render(in view: EmptySpaceCell) {
        view.heightConstraint.constant = height
        view.backgroundColor = color
    }
}
