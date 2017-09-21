public final class TitledListItemViewSpec {
    public let titleColor: UIColor
    public let titleStyle: UIViewStyle<UILabel>
    public let descriptionColor: UIColor
    public let descriptionStyle: UIViewStyle<UILabel>

    public init(titleColor: UIColor,
                titleStyle: UIViewStyle<UILabel>,
                descriptionColor: UIColor,
                descriptionStyle: UIViewStyle<UILabel>) {
        self.titleColor = titleColor
        self.titleStyle = titleStyle
        self.descriptionColor = descriptionColor
        self.descriptionStyle = descriptionStyle
    }
}
