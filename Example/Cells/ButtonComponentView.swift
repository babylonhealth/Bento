import UIKit
import FormsKit

final class ButtonComponentView: UIView {
    @IBOutlet weak var button: UIButton!
    var onButtonPressed: (() -> Void)?
    @IBAction func buttonPressed(_ sender: Any) {
        onButtonPressed?()
    }
}

final class ButtonComponent: Renderable {
    private let buttonTitle: String
    private let onBattonPressed: () -> Void
    
    init(buttonTitle: String, onBattonPressed: @escaping () -> Void) {
        self.buttonTitle = buttonTitle
        self.onBattonPressed = onBattonPressed
    }
    
    func render(in view: ButtonComponentView) {
        view.button.setTitle(buttonTitle, for: .normal)
        view.onButtonPressed = onBattonPressed
    }
}
