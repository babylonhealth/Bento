import XCTest
import UIKit
import Nimble
@testable import Bento

final class CustomInputTests: XCTestCase {
    func test_customInput_shouldDecorateAnyRenderable() {
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: 320, height: 100))

        tableView.render(
            Box.empty
                |-+ Section(id: 0)
                |---+ Node(id: 0, component:
                    A().asAnyRenderable()
                        .customInput(Node<Int>(id: 0, component: DummyComponent()))
            )
        )

        tableView.setNeedsLayout()
        tableView.layoutIfNeeded()

        XCTAssertNotNil(tableView.cellForRow(at: [0, 0]))

        tableView.render(
            Box.empty
                |-+ Section(id: 0)
                |---+ Node(id: 0, component:
                    B().asAnyRenderable()
                        .customInput(Node<Int>(id: 0, component: DummyComponent()))
            )
        )

        tableView.setNeedsLayout()
        tableView.layoutIfNeeded()

        XCTAssertNotNil(tableView.cellForRow(at: [0, 0]))
    }
}

private struct A: Renderable {
    func render(in view: UILabel) {}
}

private struct B: Renderable {
    func render(in view: UIButton) {}
}
