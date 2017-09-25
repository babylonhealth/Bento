import UIKit

public struct SelectionCellViewSpec {
    public let tick: UIImage
    public let defaultIcon: UIImage
    public let tickColor: UIColor
    public let disabledTickColor: UIColor
    public let labelStyle: UIViewStyle<UILabel>?
    public let accessoryType: UITableViewCellAccessoryType

    public init(tick: UIImage,
                tickColor: UIColor,
                disabledTickColor: UIColor,
                labelStyle: UIViewStyle<UILabel>? = nil,
                defaultIcon: UIImage,
                accessoryType: UITableViewCellAccessoryType = .none) {
        self.tick = tick
        self.tickColor = tickColor
        self.disabledTickColor = disabledTickColor
        self.labelStyle = labelStyle
        self.defaultIcon = defaultIcon
        self.accessoryType = accessoryType
    }
}
