import XCTest
import UIKit
import Nimble
@testable import Bento

final class ComponentLifecycleTests: XCTestCase {
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

    func test_component_is_lifeCycleAware_when_composed_with_other() {
        let component = DummyComponent().on()
            .deletable(deleteActionText: "", didDelete: {})

        expect(component.cast(to: ComponentLifecycleAware.self)).toNot(beNil())
    }

    func test_didMount_willUnmount() {
        let tester = MountEventTester()
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: 320, height: 100))

        tableView.render(
            Box<Int, Int>(sections: [
                Section(id: 0, items: [Node(id: 0, component: tester)])
            ]),
            animated: false
        )

        _ = tableView.cellForRow(at: IndexPath(row: 0, section: 0))!

        expect(tester.renderCount) == 1
        expect(tester.mountCount) == 1
        expect(tester.unmountCount) == 0
        expect(tester.token).toNot(beNil())

        tableView.render(
            Box<Int, Int>(sections: [
                Section(id: 0, items: [Node(id: 0, component: DummyComponent())])
            ]),
            animated: false
        )

        _ = tableView.dequeueReusableCell(withIdentifier: tester.asAnyRenderable().fullyQualifiedTypeName, for: [0, 0])

        expect(tester.renderCount) == 1
        expect(tester.mountCount) == 1
        expect(tester.unmountCount) == 1
        expect(tester.token).to(beNil())
    }
}

private class MountEventTester: Renderable {
    var renderCount = 0
    var mountCount = 0
    var unmountCount = 0
    weak var token: Token?

    init() {}

    func render(in view: UIView) {
        renderCount += 1
    }

    func willUnmount(from view: UIView, storage: ViewStorage) {
        unmountCount += 1
    }

    func didMount(to view: UIView, storage: ViewStorage) {
        mountCount += 1

        let token = Token()
        storage[testKey] = token
        self.token = token
    }
}

private class Token {}

private let testKey = ViewStorage.Key<Token>()
