import UIKit

open class FormTableView: UITableView {
    public var formStyle: FormStyle = .topYAligned
    public var preferredContentHeight: CGFloat = 0.0
    public var additionalContentInsets: UIEdgeInsets = .zero {
        didSet { setNeedsLayout() }
    }

    open override func layoutSubviews() {
        super.layoutSubviews()

        UIView.animate(withDuration: 0.30) {
            switch self.formStyle {
            case .topYAligned:
                self.contentInset = self.additionalContentInsets
            case .centerYAligned:
                self.contentInset = UIEdgeInsets(top: (self.preferredContentHeight - self.contentSize.height) * 0.5 + self.additionalContentInsets.top,
                                                 left: self.additionalContentInsets.left,
                                                 bottom: self.additionalContentInsets.bottom,
                                                 right: self.additionalContentInsets.right)
            }
        }
    }
}
