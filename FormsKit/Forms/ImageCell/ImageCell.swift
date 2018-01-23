import UIKit
import ReactiveSwift
import ReactiveCocoa
import Result

extension ImageCell: NibLoadableCell {}

final class ImageCell: FormCell {

    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var leftIconView: UIImageView!
    @IBOutlet weak var rightIconView: UIImageView!
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
            .take(until: reactive.prepareForReuse)

        self.imageWidth.constant = viewModel.imageSize.width
        self.imageHeight.constant = viewModel.imageSize.height

        setup(leftIconView, viewModel.leftIcon)
        setup(rightIconView, viewModel.rightIcon)
        setupImage(with: viewModel.imageAlignment)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if viewModel.isRounded {
            self.iconView.layer.cornerRadius = viewModel.imageSize.width / 2.0
        } else {
            self.iconView.layer.cornerRadius = 0.0
        }
    }

    private func setup(_ iconView: UIImageView, _ icons: SignalProducer<UIImage, NoError>?) {
        if let icons = icons {
            iconView.isHidden = false
            iconView.reactive.image <~ icons
                .take(until: reactive.prepareForReuse)
        } else {
            iconView.isHidden = true
            iconView.image = nil
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
