import UIKit
import ReactiveSwift
import enum Result.NoError

public enum CellElementAlignment {
    case leading
    case centered
    case trailing
}

final public class ImageCellViewModel {
    public let image: SignalProducer<UIImage, NoError>
    public let leftIcon: SignalProducer<UIImage, NoError>?
    public let rightIcon: SignalProducer<UIImage, NoError>?
    public let imageSize: CGSize
    public let visualDependencies: VisualDependenciesProtocol
    public let selectionStyle: UITableViewCellSelectionStyle
    public let imageAlignment: CellElementAlignment
    public let isRounded: Bool
    public let selected: Action<Void, Void, NoError>?

    public init(image: SignalProducer<UIImage, NoError>,
                imageSize: CGSize,
                visualDependencies: VisualDependenciesProtocol,
                selectionStyle: UITableViewCellSelectionStyle = .none,
                imageAlignment: CellElementAlignment,
                isRounded: Bool,
                selected: Action<Void, Void, NoError>? = nil,
                leftIcon: SignalProducer<UIImage, NoError>? = nil,
                rightIcon: SignalProducer<UIImage, NoError>? = nil) {
        self.image = image
        self.visualDependencies = visualDependencies
        self.selectionStyle = selectionStyle
        self.imageSize = imageSize
        self.imageAlignment = imageAlignment
        self.isRounded = isRounded
        self.selected = selected
        self.leftIcon = leftIcon
        self.rightIcon = rightIcon
    }

    public func applyBackgroundColor(to views: [UIView]) {
        self.visualDependencies.styles.backgroundTransparentColor.apply(to: views)
    }
}
