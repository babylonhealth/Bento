import UIKit
import ReactiveSwift
import ReactiveCocoa

extension ImageCell: NibLoadableCell {}

final class ImageCell: FormCell {

    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    @IBOutlet weak var imageWidth: NSLayoutConstraint!

    var viewModel: ImageCellViewModel!
    private let viewMargin: CGFloat = 14
    private var imageConstraints: [NSLayoutConstraint]!

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

    private func setupImage(with alignment: ImageCellAlignment) {
        NSLayoutConstraint.deactivate(imageConstraints ?? [])

        switch alignment {
        case .leading:
            imageConstraints = [
                iconView.topAnchor.constraint(equalTo: self.topAnchor),
                iconView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                iconView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: viewMargin)
            ]
        case .centered:
            imageConstraints = [
                iconView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
                iconView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
            ]
        case .trailing:
            imageConstraints = [
                iconView.topAnchor.constraint(equalTo: self.topAnchor),
                iconView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                iconView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -viewMargin)
            ]
        }

        NSLayoutConstraint.activate(imageConstraints)
    }
}
