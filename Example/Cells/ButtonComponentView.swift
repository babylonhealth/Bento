import UIKit
import Bento

final class ButtonComponentView: UIView, NibLoadable {
    @IBOutlet weak var button: UIButton!
    var onButtonPressed: (() -> Void)?
    @IBAction func buttonPressed(_ sender: Any) {
        onButtonPressed?()
    }
}

final class ButtonComponent: Renderable {
    private let buttonTitle: String
    private let onBattonPressed: () -> Void
    
    init(buttonTitle: String, onButtonPressed: @escaping () -> Void) {
        self.buttonTitle = buttonTitle
        self.onBattonPressed = onButtonPressed
    }
    
    func render(in view: ButtonComponentView) {
        view.button.setTitle(buttonTitle, for: .normal)
        view.onButtonPressed = onBattonPressed
    }
}
