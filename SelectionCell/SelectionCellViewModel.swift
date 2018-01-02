import UIKit
import ReactiveSwift
import Result

public final class SelectionCellViewModel {
    public enum Style {
        case disclosureIndicator
        case checkmark(Bool)
    }

    public let title: String
    public let subtitle: String?
    public let icon: Property<UIImage>?
    public let style: Style
    public let checkmark: UIImage?
    public let showsActivityIndicator: Bool
    public let select: Action<Void, Void, NoError>?
    public let discloseDetails: Action<Void, Void, NoError>?
    public let titleColor: UIColor
    public let subtitleColor: UIColor
    public let disabledTickColor: UIColor

    public init(style: Style,
                title: String,
                subtitle: String? = nil,
                icon: Property<UIImage>? = nil,
                checkmark: UIImage? = nil,
                showsActivityIndicator: Bool = false,
                select: Action<Void, Void, NoError>? = nil,
                discloseDetails: Action<Void, Void, NoError>? = nil,
                titleColor: UIColor = .black,
                subtitleColor: UIColor = .gray,
                disabledTickColor: UIColor = .gray) {
        self.style = style
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.checkmark = checkmark
        self.showsActivityIndicator = showsActivityIndicator
        self.select = select
        self.discloseDetails = discloseDetails
        self.titleColor = titleColor
        self.subtitleColor = subtitleColor
        self.disabledTickColor = disabledTickColor
    }
}
