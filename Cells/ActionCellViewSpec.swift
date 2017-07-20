public final class ActionCellViewSpec {
    public let title: String
    public let buttonStyle: UIViewStyle<UIButton>
    public let disabledButtonStyle: UIViewStyle<UIButton>?
    public let hasDynamicHeight: Bool
    public let selectionStyle: UITableViewCellSelectionStyle

    public init(title: String,
                buttonStyle: UIViewStyle<UIButton>,
                disabledButtonStyle: UIViewStyle<UIButton>? = nil,
                hasDynamicHeight: Bool,
                selectionStyle: UITableViewCellSelectionStyle = .none) {
        self.title = title
        self.buttonStyle = buttonStyle
        self.disabledButtonStyle = disabledButtonStyle
        self.selectionStyle = selectionStyle
        self.hasDynamicHeight = hasDynamicHeight
    }
}
