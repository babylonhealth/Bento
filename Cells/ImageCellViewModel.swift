import UIKit

final public class ImageCellViewModel {
    public let image: UIImage
    public let imageSize: CGSize
    public let visualDependencies: VisualDependenciesProtocol
    public let selectionStyle: UITableViewCellSelectionStyle

    public init(image: UIImage, imageSize: CGSize, visualDependencies: VisualDependenciesProtocol, selectionStyle: UITableViewCellSelectionStyle = .none) {
        self.image = image
        self.visualDependencies = visualDependencies
        self.selectionStyle = selectionStyle
        self.imageSize = imageSize
    }

    public func applyBackgroundColor(to views: [UIView]) {
        self.visualDependencies.styles.backgroundTransparentColor.apply(to: views)
    }
}
