import XCTest
import Nimble
@testable import Bento

class UIKitContainerDiffApplicationTests: XCTestCase {
    func test_mixed_operations() {
        let boxes: [Box<Int, Int>] = [
            Box(sections: [
                Section(id: 1, items: [
                    Node(id: 100, component: EmptyRenderable()),
                    Node(id: 101, component: EmptyRenderable()),
                    Node(id: 102, component: EmptyRenderable()),
                    Node(id: 103, component: EmptyRenderable())
                    ]),
                Section(id: 2, items: [
                    Node(id: 200, component: EmptyRenderable()),
                    Node(id: 201, component: EmptyRenderable())
                    ]),
                Section(id: 3, items: [
                    Node(id: 300, component: EmptyRenderable()),
                    Node(id: 301, component: EmptyRenderable())
                    ])
                ]),
            Box(sections: [
                // Inserted at 0
                Section(id: 5, items: []),
                // Moved from 2 to 1
                Section(id: 3, items: [
                    Node(id: 300, component: EmptyRenderable()),
                    Node(id: 301, component: EmptyRenderable())
                    ]),
                // Moved from 1 to 2
                Section(id: 1, items: [
                    // Moved from 3 to 0
                    Node(id: 103, component: EmptyRenderable()),
                    // Deleted #101 at 1
                    // Moved from 0 to 1
                    Node(id: 100, component: EmptyRenderable()),
                    Node(id: 102, component: EmptyRenderable())
                    ]),
                // Inserted @ 3
                Section(id: 4, items: []),
                // Moved from 2 to 4
                Section(id: 2, items: [
                    // Moved from 1 to 0
                    Node(id: 201, component: EmptyRenderable()),
                    // Inserted at 1
                    Node(id: 202, component: EmptyRenderable()),
                    // Moved from 0 to 2
                    Node(id: 200, component: EmptyRenderable())
                    ])
                ])
        ]

        verify(UITableView.self, boxes)
        verify(UICollectionView.self, boxes)
    }

    func test_insert_and_remove_the_same_element_CNSMR705() {
        let boxes: [Box<Int, Int>] = [
            Box(sections: [
                Section(id: 1, items: [
                    Node(id: 100, component: EmptyRenderable()),
                    Node(id: 101, component: EmptyRenderable()),
                    Node(id: 102, component: EmptyRenderable()),
                    Node(id: 103, component: EmptyRenderable())
                    ]),
                Section(id: 2, items: [
                    Node(id: 200, component: EmptyRenderable()),
                    Node(id: 201, component: EmptyRenderable())
                    ]),
                ]),
            Box(sections: [
                Section(id: 1, items: [
                    Node(id: 100, component: EmptyRenderable()),
                    Node(id: 101, component: EmptyRenderable()),
                    Node(id: 102, component: EmptyRenderable()),
                    Node(id: 103, component: EmptyRenderable()),
                    Node(id: 104, component: EmptyRenderable())
                    ]),
                Section(id: 2, items: [
                    Node(id: 200, component: EmptyRenderable()),
                    Node(id: 201, component: EmptyRenderable())
                    ]),
                ])
        ]

        verify(UITableView.self, boxes)
        verify(UICollectionView.self, boxes)
    }

    private func verify<View: UIView & TestableContainer>(
        _ type: View.Type,
        _ boxes: [Box<Int, Int>],
        count: Int = 10,
        file: FileString = #file,
        line: UInt = #line
    ) {
        let window = UIWindow()
        window.frame.size = CGSize(width: 400, height: 400)
        window.isHidden = false

        let view = type.make()
        window.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.pinToEdges(of: window)

        expect(
            file,
            line: line,
            expression: { () -> Void in
                for box in repeatElement(boxes, count: count).joined() {
                    view.invalidateLayout()
                    view._render(box)
                    view.layoutIfNeeded()

                    expect(view.numberOfSections) == box.sections.count

                    for (offset, section) in box.sections.enumerated() {
                        expect(view.numberOfItems(inSection: offset)) == section.items.count
                    }
                }
            }
        ).toNot(throwAssertion())
    }
}

struct EmptyRenderable: Renderable {
    func render(in view: UIView) {}
}

private protocol TestableContainer {
    var numberOfSections: Int { get }
    func numberOfItems(inSection section: Int) -> Int

    static func make() -> UIView & TestableContainer
    func _render(_ box: Box<Int, Int>)
    func invalidateLayout()
}

extension UITableView: TestableContainer {
    fileprivate static func make() -> UIView & TestableContainer {
        return UITableView(frame: .zero, style: .plain)
    }

    fileprivate func _render(_ box: Box<Int, Int>) {
        render(box)
    }

    fileprivate func invalidateLayout() {}

    fileprivate func numberOfItems(inSection section: Int) -> Int {
        return numberOfRows(inSection: section)
    }
}

extension UICollectionView: TestableContainer {
    fileprivate static func make() -> UIView & TestableContainer {
        return UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    }

    fileprivate func _render(_ box: Box<Int, Int>) {
        render(box)
    }

    fileprivate func invalidateLayout() {
        collectionViewLayout.invalidateLayout()
    }
}
