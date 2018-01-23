public struct FormViewSpec {
    public enum SeparatorVisibility {
        case betweenItemsAndSections
        case betweenItems
        case none
    }

    public let separatorVisibility: SeparatorVisibility
    public let separatorColor: UIColor
    public let style: UIViewStyle<UIView>?
    public let itemCellStyle: UIViewStyle<UIView>?

    public init(style: UIViewStyle<UIView>? = nil,
                itemCellStyle: UIViewStyle<UIView>? = nil,
                separatorVisibility: SeparatorVisibility = .betweenItemsAndSections,
                separatorColor: UIColor = .gray) {
        self.style = style
        self.itemCellStyle = itemCellStyle
        self.separatorVisibility = separatorVisibility
        self.separatorColor = separatorColor
    }
}
