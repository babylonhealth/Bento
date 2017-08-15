import BabylonUI
import UIKit

public final class ImageOptionsCellViewSpec {
    public let mediaThumbDimension: CGFloat
    public let mediaCellDimension: CGFloat
    public let destructiveButtonStyle: UIViewStyle<UIButton>
    public let mediaCellCloseIcon: UIImage
    public init(mediaCellDimension: CGFloat,
                destructiveButtonStyle: UIViewStyle<UIButton>,
                mediaThumbDimension: CGFloat,
                mediaCellCloseIcon: UIImage) {
        self.mediaCellDimension = mediaCellDimension
        self.destructiveButtonStyle = destructiveButtonStyle
        self.mediaThumbDimension = mediaThumbDimension
        self.mediaCellCloseIcon = mediaCellCloseIcon
    }
}
