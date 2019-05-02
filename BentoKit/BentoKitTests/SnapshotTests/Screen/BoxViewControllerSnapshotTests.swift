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

    func test_separatorsEnabled() {
        Device.all.forEach {
            let vm = ViewModel(state: .text("String Title"))
            let vc = BoxViewController(viewModel: vm,
                                       renderer: EmptySpaceRenderer.self,
                                       rendererConfig: (),
                                       appearance: Property(value: TestAppearance()))
            let nc = UINavigationController(rootViewController: vc)
            verify(viewController: nc, for: $0)
        }
    }

    func testWithYCenterAligned_StringTitle() {
        Device.all.forEach {
            let vm = ViewModel(state: .text("String Title"))
            let vc = BoxViewController(viewModel: vm,
                                       renderer: Renderer.self,
                                       rendererConfig: (),
                                       appearance: Property(value: TestAppearance()))
            let nc = UINavigationController(rootViewController: vc)
            verify(viewController: nc, for: $0)
        }
    }

    func testWithYCenterAligned_ViewTitle() {
        let view = UILabel()
        view.text = "View Title"
        view.layer.borderColor = UIColor.red.cgColor
        view.layer.borderWidth = 1

        Device.all.forEach {
            let vm = ViewModel(state: .view(view))
            let vc = BoxViewController(viewModel: vm,
                                       renderer: Renderer.self,
                                       rendererConfig: (),
                                       appearance: Property(value: TestAppearance()))
            let nc = UINavigationController(rootViewController: vc)
            verify(viewController: nc, for: $0)
        }
    }

    class ViewModel: BoxViewModel {
        typealias State = NavigationTitleItem
        typealias Action = Never

        let state: Property<State>

        init(state: State) {
            self.state = Property(value: state)
        }

        func send(action: Never) {}
    }

    struct TestAppearance: BoxAppearance {
        var traits = UITraitCollection()
    }

    struct Renderer: BoxRenderer {
        typealias State = NavigationTitleItem
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

        func render(state: NavigationTitleItem) -> Screen<SectionId, RowId> {
            let rightButtons = [
                BarButtonItem(appearance: .text("R"))
            ]

            let leftButtons = [
                BarButtonItem(appearance: .text("L"))
            ]
            return Screen(
                titleItem: state,
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

    struct EmptySpaceRenderer: BoxRenderer {
        typealias State = NavigationTitleItem
        typealias Action = Never
        typealias SectionId = Int
        typealias RowId = Int

        private let observer: Sink<Action>

        var configuration: BoxConfiguration {
            return BoxConfiguration(shouldUseSystemSeparators: true)
        }

        var styleSheet: ViewStyleSheet<UIView> {
            return ViewStyleSheet(backgroundColor: .white)
        }

        init(observer: @escaping Sink<Action>, appearance: TestAppearance, config: EmptyConfig) {
            self.observer = observer
        }

        func render(state: NavigationTitleItem) -> Screen<SectionId, RowId> {
            return Screen(
                titleItem: state,
                formStyle: .topYAligned,
                box: .empty
                    |-+ Section(id: 0)
                    |---+ Node(id: 0, component:
                        Component.EmptySpace(
                            height: 30,
                            styleSheet: ViewStyleSheet<UIView>()
                                .compose(\.backgroundColor, UIColor.blue.withAlphaComponent(0.05))
                        )
                    )
                    |---+ Node(id: 1, component:
                        Component.EmptySpace(
                            height: 30,
                            styleSheet: ViewStyleSheet<UIView>()
                                .compose(\.backgroundColor, UIColor.red.withAlphaComponent(0.05))
                        )
                    )
                    |---+ Node(id: 2, component:
                        Component.EmptySpace(
                            height: 30,
                            styleSheet: ViewStyleSheet<UIView>()
                                .compose(\.backgroundColor, UIColor.blue.withAlphaComponent(0.05))
                        )
                    )
                    |---+ Node(id: 3, component:
                        Component.EmptySpace(
                            height: 30,
                            styleSheet: ViewStyleSheet<UIView>()
                                .compose(\.backgroundColor, UIColor.red.withAlphaComponent(0.05))
                        )
                    )
            )
        }
    }
}
