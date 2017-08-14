import UIKit
import ReactiveSwift
import enum Result.NoError

final public class ImageCellViewModel {
    public let image: SignalProducer<UIImage, NoError>
    public let imageSize: CGSize
    public let visualDependencies: VisualDependenciesProtocol
    public let selectionStyle: UITableViewCellSelectionStyle

    public init(image: SignalProducer<UIImage, NoError>, imageSize: CGSize, visualDependencies: VisualDependenciesProtocol, selectionStyle: UITableViewCellSelectionStyle = .none) {
        self.image = image
        self.visualDependencies = visualDependencies
        self.selectionStyle = selectionStyle
        self.imageSize = imageSize
    }

    public func applyBackgroundColor(to views: [UIView]) {
        self.visualDependencies.styles.backgroundTransparentColor.apply(to: views)
    }
}
