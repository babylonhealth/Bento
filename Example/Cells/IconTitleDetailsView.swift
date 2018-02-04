import UIKit
import FormsKit

final class IconTitleDetailsView: UIView {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        iconImageView.layer.cornerRadius = iconImageView.frame.width / 2
    }
}

final class IconTitleDetailsComponent: Renderable {
    private let icon: UIImage
    private let title: String
    private let subtitle: String
    
    init(icon: UIImage, title: String, subtitle: String) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
    }
    
    func render(in view: IconTitleDetailsView) {
        view.iconImageView.image = icon
        view.titleLabel.text = title
        view.subtitleLabel.text = subtitle
    }
}
