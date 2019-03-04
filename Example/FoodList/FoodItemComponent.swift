import Bento
import UIKit

final class FoodItemComponent: Renderable {
    private let title: String
    private let body: String
    private let image: UIImage

    init(title: String,
         body: String,
         image: UIImage) {
        self.title = title
        self.body = body
        self.image = image
    }

    func render(in view: FoodItemView) {
        view.imageView.image = image
        view.titleLabel.text = title
        view.subtitleLabel.text = body
    }
}

final class FoodItemView: UIView, NibLoadable {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
}
