import UIKit
import ReactiveSwift
import Result

public enum DescriptionHorizontalLayout {
    case fill
    case centeredProportional(Float)
}

public enum DescriptionTextStyle {
    case system(UIFontTextStyle)
    case monospacedDigit(Float)
}

public final class DescriptionCellViewModel {
    public let text: String
    public let style: DescriptionTextStyle
    public let weight: UIFont.Weight?
    public let color: UIColor
    public let alignment: TextAlignment
    public let horizontalLayout: DescriptionHorizontalLayout
    public let selected: Action<Void, Void, NoError>?
    public let showsDisclosureIndicator: Bool

    public init(text: String,
                style: DescriptionTextStyle,
                weight: UIFont.Weight? = nil,
                color: UIColor = .black,
                alignment: TextAlignment = .leading,
                horizontalLayout: DescriptionHorizontalLayout = .fill,
                selected: Action<Void, Void, NoError>? = nil,
                showsDisclosureIndicator: Bool = false) {
        self.text = text
        self.style = style
        self.weight = weight
        self.color = color
        self.alignment = alignment
        self.horizontalLayout = horizontalLayout
        self.selected = selected
        self.showsDisclosureIndicator = showsDisclosureIndicator
    }
}
