public final class ActionCellViewSpec {
    public let title: String
    public let buttonStyle: UIViewStyle<UIButton>
    public let hasDynamicHeight: Bool
    public let selectionStyle: UITableViewCellSelectionStyle

    public init(title: String,
                buttonStyle: UIViewStyle<UIButton>,
                hasDynamicHeight: Bool,
                selectionStyle: UITableViewCellSelectionStyle = .none) {
        self.title = title
        self.buttonStyle = buttonStyle
        self.selectionStyle = selectionStyle
        self.hasDynamicHeight = hasDynamicHeight
    }
}
