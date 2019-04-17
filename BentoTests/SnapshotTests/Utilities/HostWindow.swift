import UIKit

final class HostWindow: UIWindow {
    private let testScreen: Device

    override var traitCollection: UITraitCollection {
        return testScreen.traits
    }

    init(screen: Device) {
        self.testScreen = screen
        super.init(frame: .init(origin: .zero, size: screen.size))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
