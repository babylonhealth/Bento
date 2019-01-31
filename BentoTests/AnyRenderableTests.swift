import Nimble
import XCTest
import UIKit
@testable import Bento

class AnyRenderableTests: XCTestCase {
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

private class TestView: UIView {
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
