import UIKit
import FormsKit

final class IconTextCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconView: UIImageView!
}

class IconTextComponent: Renderable {
    private let title: String?
    private let image: UIImage?

    init(image: UIImage? = nil,
         title: String? = nil) {
        self.image = image
        self.title = title
    }

    func render(in view: IconTextCell) {
        view.titleLabel.text = title
        view.iconView.image = image
    }
}
