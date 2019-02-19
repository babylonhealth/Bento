import Nimble
import XCTest
import UIKit
@testable import Bento

class AnyRenderableTests: XCTestCase {
    func testShouldPassthroughBehaviours() {
        let testView = TestView()

        let base = TestRenderable(reuseIdentifier: "Test",
                                  generate: { testView },
                                  render: { $0.hasInvoked = true })
        let renderable = AnyRenderable(base)

        expect(renderable.reuseIdentifier) == "Test"

        let view = renderable.generate()
        expect(view) === testView

        expect(testView.hasInvoked) == false

        renderable.render(in: testView)
        expect(testView.hasInvoked) == true
    }

    func test_should_see_view_type_through_nested_wrapping() {
        let component = TestRenderable(reuseIdentifier: "", generate: { TestView() }, render: { _ in })

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
}

private class TestView: UIView {
    var hasInvoked = false
}

private final class TestRenderable: Renderable {
    let reuseIdentifier: String
    let generateAction: () -> TestView
    let renderAction: (TestView) -> Void

    init(reuseIdentifier: String,
         generate: @escaping () -> TestView,
         render: @escaping (TestView) -> Void) {
        self.reuseIdentifier = reuseIdentifier
        self.generateAction = generate
        self.renderAction = render
    }

    func render(in view: TestView) {
        renderAction(view)
    }

    func generate() -> TestView {
        return generateAction()
    }
}
