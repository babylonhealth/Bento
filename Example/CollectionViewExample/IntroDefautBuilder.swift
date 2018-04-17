import UIKit

public struct IntroDefaultBuilder {

    public init() {}

    func makeCell(viewModel: IntroCellViewModel,
                  collectionView: UICollectionView,
                  indexPath: IndexPath) -> UICollectionViewCell
    {
        guard let cell: IntroDefaultCollectionCell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "DefaultPageCell",
            for: indexPath
            ) as? IntroDefaultCollectionCell
            else { return UICollectionViewCell() }

        cell.setup(with: viewModel)
        return cell
    }

    private func makeImageView(for content: IntroContent) -> UIView  {
        let imageView = UIImageView(image: content.image)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }
}
