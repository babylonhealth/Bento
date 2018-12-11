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
