import UIKit
import FormsKit

final class IconTextCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconView: UIImageView!
}

class IconTextComponent: Renderable {
    private let title: String?
    private let image: UIImage?
    private let renderer: ((IconTextCell) -> Void)?

    init(image: UIImage? = nil,
         title: String? = nil,
         iconImage: UIImage? = nil) {
        self.image = image
        self.title = title
        self.renderer = nil
    }
    
    init(renderer: @escaping (IconTextCell) -> Void) {
        self.renderer = renderer
        self.image = nil
        self.title = nil
    }

    func render(in view: IconTextCell) {
        view.titleLabel.text = title
        view.iconView.image = image
    }
}
