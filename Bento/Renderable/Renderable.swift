import UIKit

public struct HorizontalEdgeInsets: Equatable {
    public let leading: CGFloat
    public let trailing: CGFloat

    public init(leading: CGFloat, trailing: CGFloat) {
        self.leading = leading
        self.trailing = trailing
    }

    public init(_ insets: UIEdgeInsets) {
        self.leading = insets.left
        self.trailing = insets.right
    }

    public static var zero: HorizontalEdgeInsets {
        return HorizontalEdgeInsets(leading: 0, trailing: 0)
    }
}

public protocol Renderable: Equatable {
    associatedtype View

    var reuseIdentifier: String { get }

    func generate() -> View
    func render(in view: View)

    func height(forWidth width: CGFloat, inheritedMargins: HorizontalEdgeInsets) -> CGFloat?
    func estimatedHeight(forWidth width: CGFloat, inheritedMargins: HorizontalEdgeInsets) -> CGFloat?
}

public extension Renderable where Self: AnyObject {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs === rhs
    }
}

public extension Renderable {
    var reuseIdentifier: String {
        return String(reflecting: View.self)
    }

    public func height(forWidth width: CGFloat, inheritedMargins: HorizontalEdgeInsets) -> CGFloat? {
        return nil
    }

    public func estimatedHeight(forWidth width: CGFloat, inheritedMargins: HorizontalEdgeInsets) -> CGFloat? {
        return nil
    }
}

extension Renderable where View: UIView {
    public func sizeBoundTo(width: CGFloat, inheritedMargins: HorizontalEdgeInsets = .zero) -> CGSize {
        if let height = height(forWidth: width, inheritedMargins: inheritedMargins) {
            return CGSize(width: width, height: height)
        }

        return rendered(inheritedMargins: inheritedMargins)
            .systemLayoutSizeFitting(CGSize(width: width, height: UILayoutFittingCompressedSize.height),
                                     withHorizontalFittingPriority: .required,
                                     verticalFittingPriority: .defaultLow)
    }

    public func sizeBoundTo(height: CGFloat, inheritedMargins: HorizontalEdgeInsets = .zero) -> CGSize {
        return rendered(inheritedMargins: inheritedMargins)
            .systemLayoutSizeFitting(CGSize(width: UILayoutFittingCompressedSize.width, height: height),
                                     withHorizontalFittingPriority: .defaultLow,
                                     verticalFittingPriority: .required)
    }

    public func sizeBoundTo(size: CGSize, inheritedMargins: HorizontalEdgeInsets = .zero) -> CGSize {
        if let height = height(forWidth: size.width, inheritedMargins: inheritedMargins),
           height <= size.height {
            return CGSize(width: size.width, height: height)
        }

        return rendered(inheritedMargins: inheritedMargins)
            .systemLayoutSizeFitting(size)
    }

    private func rendered(inheritedMargins: HorizontalEdgeInsets) -> UIView {
        let view = generate()
        render(in: view)
        let margins = view.layoutMargins
        view.layoutMargins = UIEdgeInsets(top: margins.top,
                                          left: max(margins.left, inheritedMargins.leading),
                                          bottom: margins.bottom,
                                          right: max(margins.right, inheritedMargins.trailing))

        return view
    }
}

public extension Renderable where View: UIView {
    func generate() -> View {
        return View()
    }
}

public extension Renderable where View: UIView & NibLoadable {
    func generate() -> View {
        return View.loadFromNib()
    }
}
