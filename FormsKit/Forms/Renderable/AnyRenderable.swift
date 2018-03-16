import UIKit

final class AnyRenderable {
    let reuseIdentifier: String
    private let generator: () -> UIView
    private let render: (UIView) -> Void

    init<R: Renderable>(renderable: R) where R.View: UIView {
        self.reuseIdentifier = renderable.reuseIdentifier
        self.generator = renderable.generate
        self.render = { view in
            guard let view = view as? R.View else {
                assertionFailure()
                return
            }
            renderable.render(in: view)
        }
    }
    
    func render(in view: UIView) {
        self.render(view)
    }

    func generateView() -> UIView {
        return generator()
    }
}
