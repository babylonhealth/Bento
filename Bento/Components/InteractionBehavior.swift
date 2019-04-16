public struct InteractionBehavior: OptionSet {
    public static let becomeFirstResponder = InteractionBehavior(rawValue: 1 << 1)

    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}
