import UIKit

final class AnyRenderable {
    let reuseIdentifier: String
    private let generator: () -> UIView
    private let render: (UIView) -> Void

    init<R: Renderable>(renderable: R) {
        self.reuseIdentifier = renderable.reuseIdentifier
        self.generator = {
            switch renderable.strategy {
            case .`class`: return R.View()
            case .nib: return R.View.loadFromNib()
            }
        }
        self.render = { (view) in renderable.render(in: (view as! R.View)) }
    }

    func render(view: UIView) {
        self.render(view)
    }

    func generateView() -> UIView {
        return generator()
    }
}
