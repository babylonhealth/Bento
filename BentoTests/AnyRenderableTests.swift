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

    func test_layoutEquivalenceEvaluation() {
        verifyLayoutEquivalenceEvaluation(wrapper: { $0 })
    }

    func test_layoutEquivalenceEvaluation_nested() {
        verifyLayoutEquivalenceEvaluation(wrapper: { AnyRenderable($0) })
    }

    func test_layoutEquivalenceEvaluation_nestedTwice() {
        verifyLayoutEquivalenceEvaluation(wrapper: { AnyRenderable(AnyRenderable($0)) })
    }

    func test_layoutEquivalenceEvaluation_nestedWithBehaviorInjection() {
        verifyLayoutEquivalenceEvaluation(wrapper: { $0.on(willDisplayItem: nil, didEndDisplayingItem: nil) })
    }

    private func verifyLayoutEquivalenceEvaluation(
        wrapper: (AnyRenderable) -> AnyRenderable
    ) {
        let compatibility1 = AnyRenderable.layoutEquivalence(
            wrapper(AnyRenderable(TestContentRenderable(content: "LHS"))),
            wrapper(AnyRenderable(TestContentRenderable(content: "RHS")))
        )
        expect(compatibility1) == .different

        let compatibility2 = AnyRenderable.layoutEquivalence(
            wrapper(AnyRenderable(TestContentRenderable(content: "LHS"))),
            wrapper(AnyRenderable(TestContentRenderable(content: "LHS")))
        )
        expect(compatibility2) == .same

        let compatibility3 = AnyRenderable.layoutEquivalence(
            wrapper(AnyRenderable(TestContentRenderable(content: "LHS"))),
            wrapper(AnyRenderable(TestEmptyRenderable()))
        )
        expect(compatibility3) == .different

        let compatibility4 = AnyRenderable.layoutEquivalence(
            wrapper(AnyRenderable(TestEmptyRenderable())),
            wrapper(AnyRenderable(TestContentRenderable(content: "RHS")))
        )
        expect(compatibility4) == .different

        let compatibility5 = AnyRenderable.layoutEquivalence(
            wrapper(AnyRenderable(TestEmptyRenderable())),
            wrapper(AnyRenderable(TestEmptyRenderable()))
        )
        expect(compatibility5) == .unknown
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

struct TestContentRenderable: Renderable {
    let content: String

    init(content: String) {
        self.content = content
    }

    func render(in view: UIView) {}

    static func layoutEquivalence(_ lhs: TestContentRenderable, _ rhs: TestContentRenderable) -> LayoutEquivalence {
        return lhs.content == rhs.content ? .same : .different
    }
}


struct TestEmptyRenderable: Renderable {
    init() {}

    func render(in view: UIView) {}
}
