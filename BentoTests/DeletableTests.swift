import XCTest
import UIKit
import Nimble
@testable import Bento

final class DeletableTests: XCTestCase {
    func test_it_has_correct_title() {
        let section = Section(id: 0)
            |---+ Node(id: 0, component: Component()
                .deletable(deleteActionText: "Remove", didDelete: {}))
        let tableView = UITableView()
        let adapter = TableViewAdapterBase<Int, Int>(with: tableView)
        adapter.update(sections: [section])

        if #available(iOS 11.0, *) {
            let action = adapter.tableView(tableView, trailingSwipeActionsConfigurationForRowAt: IndexPath(row: 0, section: 0))

            expect(action?.actions.first?.title) == "Remove"
        }
    }

    func test_it_calls_delete() {
        var called = false
        let section = Section(id: 0)
            |---+ Node(id: 0, component: Component()
                .deletable(deleteActionText: "", didDelete: {
                    called = true
                })
            )
        let tableView = UITableView()
        let adapter = BentoTableViewAdapter<Int, Int>(with: tableView)
        tableView.delegate = adapter
        tableView.dataSource = adapter
        adapter.update(sections: [section])

        if #available(iOS 11.0, *) {
            let action = adapter.tableView(tableView, trailingSwipeActionsConfigurationForRowAt: IndexPath(row: 0, section: 0))!.actions.first!

            action.handler(action, UIView(), {_ in })
            expect(called).toEventually(beTrue())
        }
    }

    func test_it_is_deletable_after_composing_with_other() {
        let component = Component()
            .deletable(deleteActionText: "Delete", didDelete: {})
            .on()

        expect(component.cast(to: Deletable.self)).toNot(beNil())
    }

    final class Component: Renderable {
        func render(in view: UIView) {}
    }
}

