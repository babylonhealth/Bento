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

    private var view: UIView? {
        didSet {
            oldValue?.removeFromSuperview()

            view?.contentMode = .scaleAspectFit
            view?.translatesAutoresizingMaskIntoConstraints = false
            view?.add(to: self)
                .centerInSuperview()

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
        return CGSize(width: 24, height: 24)
    }

    private func accessoryTypeDidChange(old: Accessory, new: Accessory) {
        guard old != new else { return }

        let url = Bundle(for: AccessoryView.self).url(forResource: "BentoKit", withExtension: "bundle")
        let bundle = url.map(Bundle.init) ?? Bundle(for: AccessoryView.self)

        switch new {
        case .chevron:
            view = UIImage(named: "chevronNext", in: bundle, compatibleWith: nil)
                .map(UIImageView.init)
        case .activityIndicator:
            view = UIActivityIndicatorView(style: .gray)
                .with { $0.startAnimating() }
        case .checkmark:
            view = UIImage(named: "tickIcon", in: bundle, compatibleWith: nil)
                .map(UIImageView.init)
        case let .icon(image):
            view = UIImageView(image: image)
        case let .tintedIcon(image, tintColor):
            view = UIImageView(image: image)
                .with { $0.tintColor = tintColor }
        case .none:
            view = nil
        }
    }
}

extension AccessoryView {

    public enum Accessory: Equatable {
        case chevron
        case activityIndicator
        case checkmark
        case icon(UIImage)
        case tintedIcon(UIImage, UIColor)
        case none
    }
}
