import UIKit
import ReactiveSwift
import ReactiveCocoa

extension ImageCell: NibLoadableCell {}

final class ImageCell: FormCell {

    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    @IBOutlet weak var imageWidth: NSLayoutConstraint!

    var viewModel: ImageCellViewModel!

    func setup(viewModel: ImageCellViewModel) {
        self.viewModel = viewModel
        self.viewModel.applyBackgroundColor(to: [self])
        self.selectionStyle = self.viewModel.selectionStyle
        self.iconView.reactive.image <~ viewModel.image
        self.imageWidth.constant = viewModel.imageSize.width
        self.imageHeight.constant = viewModel.imageSize.height
        self.iconView.layer.cornerRadius = self.imageWidth.constant / 2.0
    }
}
