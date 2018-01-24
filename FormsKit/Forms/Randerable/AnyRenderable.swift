import UIKit

final class AnyRenderable {

    let reuseIdentifier: String
    let generator: () -> UIView
    private let _render: (UIView) -> Void

    init<R: Renderable>(renderable: R) {
        self.reuseIdentifier = renderable.reuseIdentifier
        self.generator = {
            switch renderable.strategy {
            case .`class`: return R.View()
            case .nib: return R.View.loadFromNib()
            }
        }
        self._render = { (view) in renderable.render(in: (view as! R.View)) }
    }

    func render(in view: UIView) {
        _render(view)
    }
}
