import StyleSheets
import ReactiveSwift
import UIKit
import XCTest
import Bento
import BentoKit

final class BoxViewControllerSnapshotTests: SnapshotTestCase {
    override func setUp() {
        super.setUp()
        self.recordMode = false
    }

    func testWithYCenterAligned() {
        Device.all.forEach {
            let vm = ViewModel()
            let vc = BoxViewController(viewModel: vm,
                                       renderer: Renderer.self,
                                       rendererConfig: (),
                                       appearance: Property(value: TestAppearance()))
            let nc = UINavigationController(rootViewController: vc)
            verify(viewController: nc, for: $0)
        }
    }

    class ViewModel: BoxViewModel {
        typealias State = String
        typealias Action = Never

        let state = Property(value: "Unable to connect")

        func send(action: Never) {}
    }

    struct TestAppearance: BoxAppearance {
        var traits = UITraitCollection()
    }

    struct Renderer: BoxRenderer {
        typealias State = String
        typealias Action = Never
        typealias SectionId = Int
        typealias RowId = Int

        private let observer: Sink<Action>

        var configuration: BoxConfiguration {
            return BoxConfiguration(shouldUseSystemSeparators: false)
        }

        var styleSheet: ViewStyleSheet<UIView> {
            return ViewStyleSheet(backgroundColor: .white)
        }

        init(observer: @escaping Sink<Action>, appearance: TestAppearance, config: EmptyConfig) {
            self.observer = observer
        }

        func render(state: String) -> Screen<SectionId, RowId> {
            let rightButtons = [
                BarButtonItem(appearance: .text("R"))
            ]

            let leftButtons = [
                BarButtonItem(appearance: .text("L"))
            ]
            return Screen(
                title: "Title",
                leftBarItems: leftButtons,
                rightBarItems: rightButtons,
                formStyle: .centerYAligned,
                box: .empty
                    |-+ Section(id: 0)
                    |---+ Node(id: 0, component:
                        Component.EmptySpace(
                            height: 30,
                            styleSheet: ViewStyleSheet<UIView>()
                                .compose(\.backgroundColor, .blue)
                        )
                    )
            )
        }
    }
}
