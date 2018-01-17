import UIKit

public struct TextOptionsCellViewSpec {
    public let buttonStyle: UIViewStyle<UIButton>
    public let buttonInsets: UIEdgeInsets
    public let labelStyle: UIViewStyle<UILabel>
    public let collectionTopMargin: CGFloat
    public let collectionBottomMargin: CGFloat

    public init(buttonStyle: UIViewStyle<UIButton>,
                buttonInsets: UIEdgeInsets,
                labelStyle: UIViewStyle<UILabel>,
                collectionTopMargin: CGFloat,
                collectionBottomMargin: CGFloat) {
        self.buttonStyle = buttonStyle
        self.buttonInsets = buttonInsets
        self.labelStyle = labelStyle
        self.collectionTopMargin = collectionTopMargin
        self.collectionBottomMargin = collectionBottomMargin
    }
}
