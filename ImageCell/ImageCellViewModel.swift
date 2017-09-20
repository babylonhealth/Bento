import UIKit
import ReactiveSwift
import enum Result.NoError

public enum ImageCellAlignment {
    case leading
    case centered
    case trailing
}

final public class ImageCellViewModel {
    public let image: SignalProducer<UIImage, NoError>
    public let imageSize: CGSize
    public let visualDependencies: VisualDependenciesProtocol
    public let selectionStyle: UITableViewCellSelectionStyle
    public let imageAlignment: ImageCellAlignment
    public let isRounded: Bool
    public let selected: Action<Void, Void, NoError>?

    public init(image: SignalProducer<UIImage, NoError>,
                imageSize: CGSize,
                visualDependencies: VisualDependenciesProtocol,
                selectionStyle: UITableViewCellSelectionStyle = .none,
                imageAlignment: ImageCellAlignment,
                isRounded: Bool,
                selected: Action<Void, Void, NoError>? = nil) {
        self.image = image
        self.visualDependencies = visualDependencies
        self.selectionStyle = selectionStyle
        self.imageSize = imageSize
        self.imageAlignment = imageAlignment
        self.isRounded = isRounded
        self.selected = selected
    }

    public func applyBackgroundColor(to views: [UIView]) {
        self.visualDependencies.styles.backgroundTransparentColor.apply(to: views)
    }
}
