import BabylonUI
import UIKit

public final class SelectionCellViewSpec {
    public let tick: UIImage
    public let defaultIcon: UIImage?
    public let tickColor: UIColor
    public let disabledTickColor: UIColor

    public init(tick: UIImage,
                tickColor: UIColor,
                disabledTickColor: UIColor,
                defaultIcon: UIImage? = nil) {
        self.tick = tick
        self.tickColor = tickColor
        self.disabledTickColor = disabledTickColor
        self.defaultIcon = defaultIcon
    }
}
