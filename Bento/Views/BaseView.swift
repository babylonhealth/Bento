import UIKit
import StyleSheets

public protocol BaseViewProtocol: AnyObject {
    var enforcesMinimumHeight: Bool { get set }
}

/// The base view for all components.
open class BaseView: UIView, BaseViewProtocol {
    public var enforcesMinimumHeight: Bool = false {
        didSet {
            if enforcesMinimumHeight != oldValue {
                minimumHeightConstraint.isActive = enforcesMinimumHeight
            }
        }
    }

    private var minimumHeightConstraint: NSLayoutConstraint!

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    open override func didMoveToSuperview() {
        super.didMoveToSuperview()

        if let superview = superview {
            superview.layoutMargins.top = 0.0
            superview.layoutMargins.bottom = 0.0
        }
    }

    private func setup() {
        preservesSuperviewLayoutMargins = true

        if #available(iOS 11.0, *) {
            insetsLayoutMarginsFromSafeArea = false
        }

        minimumHeightConstraint = heightAnchor.constraint(greaterThanOrEqualToConstant: 44.0)
            .withPriority(.cellRequired)
    }
}

/// The base stack view for all components.
open class BaseStackView: UIStackView, BaseViewProtocol {
    public var enforcesMinimumHeight: Bool = false {
        didSet {
            if enforcesMinimumHeight != oldValue {
                minimumHeightConstraint.isActive = enforcesMinimumHeight
            }
        }
    }
    public var cornerRadius: CGFloat = 0 {
        didSet {
            backgroundView.layer.cornerRadius = cornerRadius
            backgroundView.layer.masksToBounds = true
        }
    }

    private var minimumHeightConstraint: NSLayoutConstraint!
    
    fileprivate lazy var backgroundView: UIView = {
        let view = UIView()

        insertSubview(view, at: 0)
        view.pinEdges(to: self)

        return view
    }()

    open override var backgroundColor: UIColor? {
        get {
            return backgroundView.backgroundColor
        }
        set {
            backgroundView.backgroundColor = newValue
        }
    }

    public var borderColor: CGColor? {
        get {
            return backgroundView.layer.borderColor
        }
        set {
            backgroundView.layer.borderColor = newValue
        }
    }

    public var borderWidth: CGFloat {
        get {
            return backgroundView.layer.borderWidth
        }
        set {
            backgroundView.layer.borderWidth = newValue
        }
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    open override func didMoveToSuperview() {
        super.didMoveToSuperview()

        if let superview = superview {
            superview.layoutMargins.top = 0.0
            superview.layoutMargins.bottom = 0.0
        }
    }

    private func setup() {
        isLayoutMarginsRelativeArrangement = true
        preservesSuperviewLayoutMargins = true

        if #available(iOS 11.0, *) {
            insetsLayoutMarginsFromSafeArea = false
        }

        minimumHeightConstraint = heightAnchor.constraint(greaterThanOrEqualToConstant: 44.0)
            .withPriority(.cellRequired)
    }
}

open class BaseViewStyleSheet<View: UIView & BaseViewProtocol>: ViewStyleSheet<View> {
    public var enforcesMinimumHeight: Bool

    public init(
        backgroundColor: UIColor? = nil,
        tintColor: UIColor? = nil,
        clipsToBounds: Bool = false,
        layoutMargins: UIEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8),
        transform: CGAffineTransform = .identity,
        cornerRadius: CGFloat = 0.0,
        masksToBounds: Bool = false,
        enforcesMinimumHeight: Bool = true
        ) {
        self.enforcesMinimumHeight = enforcesMinimumHeight
        super.init(backgroundColor: backgroundColor,
                   tintColor: tintColor,
                   clipsToBounds: clipsToBounds,
                   layoutMargins: layoutMargins,
                   transform: transform,
                   cornerRadius: cornerRadius,
                   masksToBounds: masksToBounds)
    }

    open override func apply(to element: View) {
        super.apply(to: element)
        element.enforcesMinimumHeight = enforcesMinimumHeight
    }
}

open class InteractiveViewStyleSheet<View: InteractiveView>: BaseViewStyleSheet<View> {
    public var highlightColor: UIColor?

    public init(
        enforcesMinimumHeight: Bool = true,
        highlightColor: UIColor? = UIColor(red: 239 / 255.0, green: 239 / 255.0, blue: 244 / 255.0, alpha: 1)
    ) {
        self.highlightColor = highlightColor
        super.init(enforcesMinimumHeight: enforcesMinimumHeight)
    }

    open override func apply(to element: View) {
        super.apply(to: element)
        element.highlightingGesture.highlightColor = highlightColor
    }
}
