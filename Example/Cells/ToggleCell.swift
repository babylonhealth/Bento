import UIKit
import FormsKit

class ToggleCell: UITableViewCell {
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var toggle: UISwitch!
    @IBOutlet weak var iconWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var iconLabelSpacingConstraint: NSLayoutConstraint!
    
    var onToggle: ((Bool) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        toggle.addTarget(self,
                         action: #selector(ToggleCell.onToggleChange),
                         for: .valueChanged)
    }
    
    @objc private func onToggleChange() {
        onToggle?(toggle.isOn)
    }
}

class ToggleComponent: Renderable {
    private let isOn: Bool
    private let title: String?
    private let icon: UIImage?
    private let onToggle: ((Bool) -> Void)?
    
    init(isOn: Bool,
         title: String? = nil,
         icon: UIImage? = nil,
         onToggle: ((Bool) -> Void)?) {
        self.isOn = isOn
        self.title = title
        self.icon = icon
        self.onToggle = onToggle
    }

    func render() -> ToggleCell {
        let cell = ToggleCell.loadFromNib()
        
        cell.iconView.image = icon
        cell.titleLabel.text = title
        cell.toggle.isOn = isOn
        cell.onToggle = onToggle
        
        return cell
    }

    func update(view: ToggleCell) {
        view.iconView.image = icon
        view.titleLabel.text = title
        view.toggle.isOn = isOn
        view.onToggle = onToggle
    }

}
