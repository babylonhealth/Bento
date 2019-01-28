@testable import Bento
import Foundation
import Nimble
import XCTest

final class RenderObservingComponentTests: XCTestCase {
    func test_it_calls_didRender() {
        var called = false
        let section = Section(id: 0)
            |---+ Node(id: 0, component: DummyComponent()
                .on { _ in
                    called = true
                }
            )
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: 320, height: 100))
        let adapter = BentoTableViewAdapter<Int, Int>(with: tableView)
        tableView.delegate = adapter
        tableView.dataSource = adapter
        adapter.update(sections: [section])

        tableView.setNeedsLayout()
        tableView.layoutIfNeeded()

        expect(called) == true
    }

    func test_componend_is_renderObserving_when_composed_with_other() {
        let component = DummyComponent()
            .on(didRender: { _ in })
            .deletable(deleteActionText: "") {}

        expect(component.cast(to: RenderObserving.self)).toNot(beNil())
    }
}
