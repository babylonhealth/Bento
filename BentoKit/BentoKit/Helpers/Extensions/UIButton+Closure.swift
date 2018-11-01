import UIKit

extension UIBarButtonItem {
    private var key: UnsafeRawPointer {
        return unsafeBitCast(#selector(didTapBarButtonItem), to: UnsafeRawPointer.self)
    }

    public var didTap: (() -> Void)? {
        get {
            return objc_getAssociatedObject(self, key) as! (() -> Void)?
        }
        set {
            objc_setAssociatedObject(self, key, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            self.target = self
            self.action = #selector(self.didTapBarButtonItem)
        }
    }

    public convenience init(title: String? = nil, image: UIImage? = nil, style: UIBarButtonItem.Style, action: @escaping () -> Void) {
        self.init()
        self.title = title
        self.image = image
        self.style = style
        self.didTap = action
    }

    @objc(bentoDidTapBarButtonItem) private func didTapBarButtonItem() {
        didTap?()
    }
}
