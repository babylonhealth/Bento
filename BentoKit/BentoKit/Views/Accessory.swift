import UIKit

public final class AccessoryView: InteractiveView {
    public var accessory: Accessory = .none {
        didSet {
            accessoryTypeDidChange(old: oldValue, new: accessory)
        }
    }

    public var didTap: (() -> Void)? {
        didSet {
            highlightingGesture.didTap = didTap.map(HighlightingGesture.TapAction.resign)
        }
    }

    public var interactionBehavior: InteractionBehavior {
        get { return highlightingGesture.interactionBehavior }
        set { highlightingGesture.interactionBehavior = newValue }
    }

    private var view: UIView? {
        didSet {
            oldValue?.removeFromSuperview()

            view?.contentMode = .scaleAspectFit
            view?.translatesAutoresizingMaskIntoConstraints = false
            view?.add(to: self)
                .pinEdges(to: self)

            isHidden = view == nil
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        isHidden = true

        setContentHuggingPriority(.required, for: .horizontal)
        setContentHuggingPriority(.required, for: .vertical)
        setContentCompressionResistancePriority(.required, for: .horizontal)
        setContentCompressionResistancePriority(.cellRequired, for: .vertical)
    }

    @available(*, unavailable)
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override var intrinsicContentSize: CGSize {
        if case let .custom(view) = accessory {
            view.layoutIfNeeded()
            return view.frame.size
        }
        return CGSize(width: 24, height: 24)
    }

    private func accessoryTypeDidChange(old: Accessory, new: Accessory) {
        guard old != new else { return }

        switch new {
        case .chevron:
            view = UIImage(named: "chevronNext", in: Resources.bundle, compatibleWith: nil)
                .map(UIImageView.init)
        case .activityIndicator:
            view = UIActivityIndicatorView(style: .gray)
                .with { $0.startAnimating() }
        case .checkmark:
            view = UIImage(named: "tickIcon", in: Resources.bundle, compatibleWith: nil)
                .map(UIImageView.init)
        case let .icon(image):
            view = UIImageView(image: image)
        case let .tintedIcon(image, tintColor):
            view = UIImageView(image: image)
                .with { $0.tintColor = tintColor }
        case let .custom(customView):
            view = customView
        case .none:
            view = nil
        }
        invalidateIntrinsicContentSize()
    }
}

extension AccessoryView {

    public enum Accessory: Equatable {
        case chevron
        case activityIndicator
        case checkmark
        case icon(UIImage)
        case tintedIcon(UIImage, UIColor)
        case custom(UIView)
        case none
    }
}
