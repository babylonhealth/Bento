import BabylonUI
import UIKit

public final class TextOptionsCellViewSpec {
    public let cellHeight: CGFloat
    public let buttonStyle: UIViewStyle<UIButton>
    public let buttonFont: UIFont
    public let buttonOffset: CGSize
    public let collectionHeight: CGFloat
    public init(cellHeight: CGFloat,
                buttonStyle: UIViewStyle<UIButton>,
                buttonFont: UIFont,
                buttonOffset: CGSize,
                collectionHeight: CGFloat) {
        self.cellHeight = cellHeight
        self.buttonStyle = buttonStyle
        self.buttonFont = buttonFont
        self.buttonOffset = buttonOffset
        self.collectionHeight = collectionHeight
    }
}

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
