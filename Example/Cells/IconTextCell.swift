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
    
    func render() -> IconTextCell {
        let cell = IconTextCell.loadFromNib()
        
        cell.titleLabel.text = title
        cell.iconView.image = image
        
        renderer?(cell)
        
        return cell
    }

    func update(view: IconTextCell) {
        view.titleLabel.text = title
        view.iconView.image = image
    }
}
