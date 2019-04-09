import XCTest
import UIKit
import Nimble
@testable import Bento

final class ReusabilityHintCombinerTests: XCTestCase {
    func test_combine_A() {
        let expectedSymbol = "BentoTests.ComponentA"

        let combiner = ReusabilityHintCombiner(root: ComponentA())
        let symbol = combiner.generate()

        expect(symbol) == String(reflecting: ComponentA.self)
        expect(symbol) == expectedSymbol
    }

    func test_combine_AB() {
        let expectedSymbol = "BentoTests.ComponentA,BentoTests.ComponentB"

        var combiner = ReusabilityHintCombiner(root: ComponentA())
        combiner.combine(ComponentB())
        let symbol = combiner.generate()

        expect(symbol) == [
            String(reflecting: ComponentA.self),
            String(reflecting: ComponentB.self)
        ].joined(separator: ",")
        expect(symbol) == expectedSymbol
    }

    func test_combine_BA() {
        let expectedSymbol = "BentoTests.ComponentB,BentoTests.ComponentA"

        var combiner = ReusabilityHintCombiner(root: ComponentB())
        combiner.combine(ComponentA())
        let symbol = combiner.generate()

        expect(symbol) == [
            String(reflecting: ComponentB.self),
            String(reflecting: ComponentA.self)
        ].joined(separator: ",")
        expect(symbol) == expectedSymbol
    }

    func test_combine_ABC() {
        let expectedSymbol = "BentoTests.ComponentA,BentoTests.ComponentB,BentoTests.ComponentC"

        var combiner = ReusabilityHintCombiner(root: ComponentA())
        combiner.combine(ComponentB())
        combiner.combine(ComponentC())
        let symbol = combiner.generate()

        expect(symbol) == [
            String(reflecting: ComponentA.self),
            String(reflecting: ComponentB.self),
            String(reflecting: ComponentC.self)
        ].joined(separator: ",")
        expect(symbol) == expectedSymbol
    }

    func test_reuseIdentifier_single() {
        let expectedSymbol = "BentoTests.ComponentA"
        let symbol = ComponentA().reuseIdentifier

        expect(symbol) == String(reflecting: ComponentA.self)
        expect(symbol) == expectedSymbol
    }

    func test_reuseIdentifier_containerOfAB() {
        let expectedSymbol = "BentoTests.ContainerOfAB,BentoTests.ComponentA,BentoTests.ComponentB"
        let symbol = ContainerOfAB().reuseIdentifier

        expect(symbol) == [
            String(reflecting: ContainerOfAB.self),
            String(reflecting: ComponentA.self),
            String(reflecting: ComponentB.self)
        ].joined(separator: ",")
        expect(symbol) == expectedSymbol
    }

    func test_reuseIdentifier_containerOfContainerOfAB() {
        let expectedSymbol = "BentoTests.ContainerOfContainerOfAB,BentoTests.ContainerOfAB,BentoTests.ComponentA,BentoTests.ComponentB"
        let symbol = ContainerOfContainerOfAB().reuseIdentifier

        expect(symbol) == [
            String(reflecting: ContainerOfContainerOfAB.self),
            String(reflecting: ContainerOfAB.self),
            String(reflecting: ComponentA.self),
            String(reflecting: ComponentB.self)
        ].joined(separator: ",")
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
internal struct ContainerOfAB: ReusabilityHintRenderable {
    internal func makeReusabilityHint(using combiner: inout ReusabilityHintCombiner) {
        combiner.combine(ComponentA())
        combiner.combine(ComponentB())
    }
}
internal struct ContainerOfContainerOfAB: ReusabilityHintRenderable {
    func makeReusabilityHint(using combiner: inout ReusabilityHintCombiner) {
        combiner.combine(ContainerOfAB())
    }
}
