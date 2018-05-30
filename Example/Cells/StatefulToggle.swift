import UIKit
import Bento

final class StatefulToggle: Renderable {
    private var isOn: Bool
    private let title: String?
    private let icon: UIImage?
    private var height = 60 as CGFloat
    
    init(isOn: Bool,
         title: String? = nil,
         icon: UIImage? = nil) {
        self.isOn = isOn
        self.title = title
        self.icon = icon
    }
    
    func render(in view: StatefulToggleView) {
        view.iconView.image = icon
        view.titleLabel.text = title
        view.toggle.setOn(isOn, animated: true)
        view.heightConstraint.constant = height
        view.onToggle = { [weak view] enabled in
            self.isOn = enabled
            self.height = enabled ? 60 : 120
            view?.heightConstraint.constant = self.height
            self.reload()
        }
    }
}

class StatefulToggleView: UIView, NibLoadable {
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var toggle: UISwitch!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    var onToggle: ((Bool) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        toggle.addTarget(self,
                         action: #selector(StatefulToggleView.onToggleChange),
                         for: .valueChanged)
    }
    
    @objc private func onToggleChange() {
        onToggle?(toggle.isOn)
    }
}



