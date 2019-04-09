import XCTest
import UIKit
import Nimble
@testable import Bento

final class ReusabilityHintTests: XCTestCase {
    func test_combine_A() {
        let expectedSymbol = "BentoTests.ComponentA[]"

        let combiner = ReusabilityHint(root: ComponentA())
        let symbol = combiner.generate()

        expect(symbol) == expectedSymbol
    }

    func test_combine_AB() {
        let expectedSymbol = "BentoTests.ComponentA[BentoTests.ComponentB[]]"

        var combiner = ReusabilityHint(root: ComponentA())
        combiner.combine(ComponentB())

        let symbol = combiner.generate()
        expect(symbol) == expectedSymbol
    }

    func test_combine_BA() {
        let expectedSymbol = "BentoTests.ComponentB[BentoTests.ComponentA[]]"

        var combiner = ReusabilityHint(root: ComponentB())
        combiner.combine(ComponentA())

        let symbol = combiner.generate()
        expect(symbol) == expectedSymbol
    }

    func test_combine_ABC() {
        let expectedSymbol = "BentoTests.ComponentA[BentoTests.ComponentB[]BentoTests.ComponentC[]]"

        var combiner = ReusabilityHint(root: ComponentA())
        combiner.combine(ComponentB())
        combiner.combine(ComponentC())

        let symbol = combiner.generate()
        expect(symbol) == expectedSymbol
    }

    func test_should_be_compatible_to_itself() {
        let hint = Container([]).reusabilityHint

        expect(hint.isCompatible(with: hint)) == true
    }

    func test_should_be_compatible_to_itself_with_children() {
        let hint = Container([
            ComponentA().asAnyRenderable(),
            ComponentB().asAnyRenderable()
        ]).reusabilityHint

        expect(hint.isCompatible(with: hint)) == true
    }

    func test_trees_that_are_equal_after_flattening_should_not_be_considered_compatible() {
        let lhs = Container([
            Container([
                Container([]).asAnyRenderable()
            ]).asAnyRenderable()
        ]).reusabilityHint
        let rhs = Container([
            Container([]).asAnyRenderable(),
            Container([]).asAnyRenderable()
        ]).reusabilityHint

        expect(lhs.isCompatible(with: rhs)) == false
        expect(lhs.generate()) != rhs.generate()
    }

    func test_reuseIdentifier_single() {
        let expectedSymbol = "BentoTests.ComponentA[]"
        let symbol = ComponentA().reuseIdentifier

        expect(symbol) == expectedSymbol
    }

    func test_reuseIdentifier_containerOfAB() {
        let expectedSymbol = "BentoTests.Container[BentoTests.ComponentA[]BentoTests.ComponentB[]]"
        let symbol = Container([
            ComponentA().asAnyRenderable(),
            ComponentB().asAnyRenderable()
        ]).reuseIdentifier
        expect(symbol) == expectedSymbol
    }

    func test_reuseIdentifier_containerOfContainerOfAB() {
        let expectedSymbol = "BentoTests.Container[BentoTests.Container[BentoTests.ComponentA[]BentoTests.ComponentB[]]]"
        let symbol = Container([
            Container([
                ComponentA().asAnyRenderable(),
                ComponentB().asAnyRenderable()
            ]).asAnyRenderable()
        ]).reuseIdentifier
        expect(symbol) == expectedSymbol
    }
}

private protocol ReusabilityHintRenderable: Renderable {}
extension ReusabilityHintRenderable {
    func render(in view: UIView) {}
}

// NOTE: Marked as internal so that the fully qualified type name (needed by a test assertion) does not depend on the
//       source location.
internal struct ComponentA: ReusabilityHintRenderable {}
internal struct ComponentB: ReusabilityHintRenderable {}
internal struct ComponentC: ReusabilityHintRenderable {}
internal struct Container: ReusabilityHintRenderable {
    let children: [AnyRenderable]

    init(_ children: [AnyRenderable]) {
        self.children = children
    }

    internal func makeReusabilityHint(_ hint: inout ReusabilityHint) {
        children.forEach { hint.combine($0) }
    }
}
