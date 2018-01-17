public struct TitledListCellViewSpec {
    public let titleColor: UIColor
    public let titleStyle: UIViewStyle<UILabel>
    public let itemViewSpec: TitledListItemViewSpec

    public init(titleColor: UIColor,
                titleStyle: UIViewStyle<UILabel>,
                itemViewSpec: TitledListItemViewSpec) {
        self.titleColor = titleColor
        self.titleStyle = titleStyle
        self.itemViewSpec = itemViewSpec
    }
}
