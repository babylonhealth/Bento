import UIKit
import ReactiveSwift
import ReactiveCocoa

extension ImageCell: NibLoadableCell {}

final class ImageCell: FormCell {

    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    @IBOutlet weak var imageWidth: NSLayoutConstraint!

    var viewModel: ImageCellViewModel!
    private var imageConstraints: [NSLayoutConstraint]!
    private var tapRecognizer: UITapGestureRecognizer!

    override func awakeFromNib() {
        super.awakeFromNib()
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.userDidTapIconView))
        iconView.addGestureRecognizer(tapRecognizer)        
        iconView.reactive.isUserInteractionEnabled <~ isFormEnabled
    }

    func setup(viewModel: ImageCellViewModel) {
        self.viewModel = viewModel
        self.selectionStyle = self.viewModel.selectionStyle
        self.viewModel.applyBackgroundColor(to: [self])
        self.iconView.reactive.image <~ viewModel.image
        self.imageWidth.constant = viewModel.imageSize.width
        self.imageHeight.constant = viewModel.imageSize.height

        setupImage(with: viewModel.imageAlignment)

        if viewModel.isRounded {
            self.iconView.layer.cornerRadius = self.imageWidth.constant / 2.0
        }
    }

    private func setupImage(with alignment: CellElementAlignment) {
        NSLayoutConstraint.deactivate(imageConstraints ?? [])

        switch alignment {
        case .leading:
            imageConstraints = [
                iconView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor)
            ]
        case .centered:
            imageConstraints = [
                iconView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            ]
        case .trailing:
            imageConstraints = [
                iconView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor)
            ]
        }

        NSLayoutConstraint.activate(imageConstraints)
    }

    @objc private func userDidTapIconView() {
        viewModel?.selected?.apply().start()
    }
}
