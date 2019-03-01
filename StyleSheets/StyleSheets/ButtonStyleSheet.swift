import UIKit

open class ButtonStyleSheet: ViewStyleSheet<UIButton>, TextBoundComputing {
    
    private let titleColors: [State : UIColor?]
    private let images: [State : UIImage?]
    private let backgroundImages: [State : UIImage?]
    public var textFont: UIFont
    public var contentHorizontalAlignment: UIControl.ContentHorizontalAlignment
    public var contentEdgeInsets: UIEdgeInsets
    public var imageEdgeInsets: UIEdgeInsets
    public var textAlignment: TextAlignment = .center
    
    open var textAttributes: [NSAttributedString.Key: Any] {
        return [.font: textFont]
    }
    public var numberOfLines: Int
    public var lineBreakMode: NSLineBreakMode
    
    public init(
        textFont: UIFont = UIFont.preferredFont(forTextStyle: .body),
        contentHorizontalAlignment: UIControl.ContentHorizontalAlignment = .center,
        titleColors: [State : UIColor?] = [:],
        images: [State : UIImage?] = [:],
        backgroundImages: [State : UIImage?] = [:],
        contentEdgeInsets: UIEdgeInsets = .zero,
        imageEdgeInsets: UIEdgeInsets = .zero,
        numberOfLines: Int = 1,
        lineBreakMode: NSLineBreakMode = .byTruncatingMiddle
        ) {
        self.textFont = textFont
        self.contentHorizontalAlignment = contentHorizontalAlignment
        self.titleColors = titleColors
        self.images = images
        self.backgroundImages = backgroundImages
        self.contentEdgeInsets = contentEdgeInsets
        self.imageEdgeInsets = imageEdgeInsets
        self.numberOfLines = numberOfLines
        self.lineBreakMode = lineBreakMode
    }
    
    open override func apply(to button: UIButton) {
        super.apply(to: button)
        
        button.titleLabel?.font = textFont
        button.titleLabel?.numberOfLines = numberOfLines
        button.titleLabel?.textAlignment = textAlignment.systemValue(for: button.effectiveUserInterfaceLayoutDirection)
        button.titleLabel?.lineBreakMode = lineBreakMode
        button.contentHorizontalAlignment = contentHorizontalAlignment
        
        titleColors
            .merging(defaultValuesPerState()) { customised, _ in customised }
            .map { ($0.key.asControlState, $0.value) }
            .forEach { button.setTitleColor($0.1, for: $0.0) }
        
        images
            .merging(defaultValuesPerState()) { customised, _ in customised }
            .map { ($0.key.asControlState, $0.value) }
            .forEach { button.setImage($0.1, for: $0.0) }
        
        backgroundImages
            .merging(defaultValuesPerState()) { customised, _ in customised }
            .map { ($0.key.asControlState, $0.value) }
            .forEach { button.setBackgroundImage($0.1, for: $0.0) }
        
        button.contentEdgeInsets = contentEdgeInsets
        button.imageEdgeInsets = imageEdgeInsets
    }
    
    public func image(for state: State) -> UIImage? {
        return images[state] ?? nil
    }
    
    public func titleColor(for state: State) -> UIColor? {
        return titleColors[state] ?? nil
    }
    
    public func backgroundImage(for state: State) -> UIImage? {
        return backgroundImages[state] ?? nil
    }
    
    private func defaultValuesPerState<T>() -> [State : T?] {
        return [
            .normal : nil,
            .selected : nil,
            .disabled : nil,
            .highlighted : nil,
            .focused : nil
        ]
    }
}

extension ButtonStyleSheet {
    
    public struct State : OptionSet, Hashable {
        
        public let rawValue: UInt
        
        var asControlState: UIControl.State {
            return UIControl.State(rawValue: rawValue)
        }
        
        public init(rawValue: UInt) {
            self.rawValue = rawValue
        }
        
        public static var normal = State(rawValue: UIControl.State.normal.rawValue)
        
        public static var highlighted = State(rawValue: UIControl.State.highlighted.rawValue)
        
        public static var disabled = State(rawValue: UIControl.State.disabled.rawValue)
        
        public static var selected = State(rawValue: UIControl.State.selected.rawValue)
        
        public static var focused = State(rawValue: UIControl.State.focused.rawValue)
        
        public static var application = State(rawValue: UIControl.State.application.rawValue)
        
        public static var reserved = State(rawValue: UIControl.State.reserved.rawValue)
    }
}
