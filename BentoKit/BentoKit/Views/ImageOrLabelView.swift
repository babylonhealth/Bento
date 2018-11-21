import UIKit
import ReactiveSwift
import StyleSheets
import ReactiveCocoa

public typealias ImageOrLabel = ImageOrLabelView.Content

open class ImageOrLabelView: UIView {

    public static func labelStyleSheet(font: UIFont) -> LabelStyleSheet {
        return LabelStyleSheet(font: font,
                               textAlignment: .center,
                               numberOfLines: 1)
    }

    public final class StyleSheet: ViewStyleSheet<ImageOrLabelView> {
        public var fixedSize: CGSize?
        public let image: ImageViewStyleSheet
        public let label: LabelStyleSheet

        public init(
            fixedSize: CGSize? = nil,
            imageEdgeInsets: UIEdgeInsets = .zero,
            backgroundColor: UIColor? = nil,
            cornerRadius: CGFloat = 0.0,
            image: ImageViewStyleSheet = ImageViewStyleSheet(),
            label: LabelStyleSheet = .init()
        ) {
            self.fixedSize = fixedSize
            self.image = image
            self.label = label

            super.init(backgroundColor: backgroundColor,
                       layoutMargins: imageEdgeInsets,
                       cornerRadius: cornerRadius,
                       masksToBounds: true)
        }

        public override func apply(to view: ImageOrLabelView) {
            super.apply(to: view)
            label.apply(to: view.label)
            image.apply(to: view.imageView)
            view.fixedSize = fixedSize
        }
    }

    public enum Content: Equatable {
        case image(UIImage)
        case text(String)
        case none
    }

    public var content: Content = .none {
        didSet {
            guard oldValue != content else { return }
            contentDidChange()
        }
    }

    public var fixedSize: CGSize? {
        didSet {
            guard oldValue != fixedSize else { return }
            sizeDidChange()
        }
    }

    open override func layoutMarginsDidChange() {
        super.layoutMarginsDidChange()
        sizeDidChange()
    }

    private let label = UILabel()
    private let imageView = UIImageView().with {
        $0.setContentCompressionResistancePriority(.fittingSizeLevel, for: .horizontal)
        $0.setContentCompressionResistancePriority(.fittingSizeLevel, for: .vertical)
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    open override var intrinsicContentSize: CGSize {
        if let fixedSize = fixedSize {
            return fixedSize
        }

        guard imageView.isHidden == false
            else { return label.intrinsicContentSize }

        var size = imageView.intrinsicContentSize
        size.width += (layoutMargins.left + layoutMargins.right)
        size.height += (layoutMargins.top + layoutMargins.bottom)
        return size
    }
}

public extension Reactive where Base: ImageOrLabelView {
    public var content: BindingTarget<ImageOrLabelView.Content> {
        return self[\.content]
    }
}

private extension ImageOrLabelView {

    func setup() {
        if #available(iOS 11, *) {
            insetsLayoutMarginsFromSafeArea = false
        }
        backgroundColor = .clear
        label.add(to: self).pinEdges(to: self)
        imageView.add(to: self).pinEdges(to: layoutMarginsGuide)
    }

    func setImage(_ image: UIImage?) {
        imageView.image = image
        imageView.isHidden = (image == nil)
    }

    func contentDidChange() {
        switch content {
        case let .image(image):
            label.text = nil
            setImage(image)
        case let .text(text):
            label.text = text
            setImage(nil)
        case .none:
            label.text = nil
            setImage(nil)
        }
        invalidateIntrinsicContentSize()
    }

    func sizeDidChange() {
        invalidateIntrinsicContentSize()
        setNeedsLayout()
    }
}
