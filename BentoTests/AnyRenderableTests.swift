import Nimble
import XCTest
import UIKit
@testable import Bento

class AnyRenderableTests: XCTestCase {
    func test_should_see_view_type_through_nested_wrapping() {
        let component = TestRenderable(render: { _ in })

        func wrapping(component: TestRenderable, count: Int) -> AnyRenderable {
            precondition(count >= 1)
            return count > 1
                ? AnyRenderable(wrapping(component: component, count: count - 1))
                : AnyRenderable(component)
        }

        expect(wrapping(component: component, count: 1).viewType) === TestView.self
        expect(wrapping(component: component, count: 2).viewType) === TestView.self
        expect(wrapping(component: component, count: 3).viewType) === TestView.self
        expect(wrapping(component: component, count: 4).viewType) === TestView.self
        expect(wrapping(component: component, count: 5).viewType) === TestView.self
        expect(wrapping(component: component, count: 6).viewType) === TestView.self
        expect(wrapping(component: component, count: 7).viewType) === TestView.self
    }

    func testShouldPassthroughBehaviours() {
        verifyBehaviorPassthrough(AnyRenderable.init)
    }

    func testShouldPassthroughBehavioursWhenBeingNested() {
        verifyBehaviorPassthrough { AnyRenderable(AnyRenderable($0)) }
    }

    func testShouldPassthroughBehavioursWhenBeingNestedTwice() {
        verifyBehaviorPassthrough { AnyRenderable(AnyRenderable(AnyRenderable($0))) }
    }

    private func verifyBehaviorPassthrough(_ factory: (TestRenderable) -> AnyRenderable) {
        let base = TestRenderable(render: { $0.hasInvoked = true })
        let renderable = factory(base)

        expect(renderable.viewType) === TestView.self
        expect(renderable.componentType) === TestRenderable.self

        let view = renderable.viewType.generate()
        expect(type(of: view)) === TestView.self

        if let view = view as? TestView {
            expect(view.hasInvoked) == false

            renderable.render(in: view)
            expect(view.hasInvoked) == true
        } else {
            fail("Expecting `TestView` in `view`, got `\(String(describing: type(of: view)))`.")
        }
    }
}

internal class TestView: UIView {
    var hasInvoked = false
}

private final class TestRenderable: Renderable {
    let renderAction: (TestView) -> Void

    init(render: @escaping (TestView) -> Void) {
        self.renderAction = render
    }

    func render(in view: TestView) {
        renderAction(view)
    }
}
