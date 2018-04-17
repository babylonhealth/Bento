import UIKit

public final class IntroDefaultCollectionCell: UICollectionViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var body: UILabel!
    @IBOutlet weak var cellHeaderContainer: UIView!

    private var viewModel: IntroCellViewModel!
    private var imageView: UIView!

    func setup(with viewModel: IntroCellViewModel) {
        self.viewModel = viewModel
        self.viewModel.setupTitle(with: title)
        self.viewModel.setupBody(with: body)
        self.imageView = UIImageView(image: viewModel.content.image)

        self.cellHeaderContainer.addSubview(self.imageView)
        self.imageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            self.imageView.widthAnchor.constraint(equalTo: self.cellHeaderContainer.widthAnchor),
            self.imageView.heightAnchor.constraint(equalTo: self.cellHeaderContainer.heightAnchor)
        ])
    }
}
