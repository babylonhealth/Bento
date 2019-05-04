import XCTest
import UIKit
import Nimble
@testable import Bento

final class ComponentLifecycleAwareTests: XCTestCase {

    func test_it_calls_willDisplayItem() {
        var called = false
        let section = Section(id: 0)
            |---+ Node(id: 0, component: DummyComponent()
                .on(willDisplayItem: {
                    called = true
                }))
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: 320, height: 100))
        let adapter = BentoTableViewAdapter<Int, Int>(with: tableView)
        tableView.delegate = adapter
        tableView.dataSource = adapter
        adapter.update(sections: [section])

        tableView.setNeedsLayout()
        tableView.layoutIfNeeded()

        expect(called) == true
    }

    func test_it_calls_didEndDisplayItem() {
        var called = false
        let section = Section(id: 0)
            |---+ Node(id: 0, component: DummyComponent()
                .on(didEndDisplayingItem: {
                    called = true
                }))
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: 320, height: 100))
        let adapter = BentoTableViewAdapter<Int, Int>(with: tableView)
        tableView.delegate = adapter
        tableView.dataSource = adapter
        adapter.update(sections: [section])

        tableView.setNeedsLayout()
        tableView.layoutIfNeeded()

        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0))!

        adapter.tableView(tableView, didEndDisplaying: cell, forRowAt: IndexPath(row: 0, section: 0))

        expect(called) == true
    }
}
