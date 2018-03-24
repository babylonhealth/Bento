import Nimble
import XCTest
import UIKit
@testable import FormsKit

class NodeTests: XCTestCase {
    func testEqaulity() {
        expect(template) == template
    }

    func testEqualityMutatedComponent() {
        expect(template) != Node(id: TestRowId.first,
                                 component: TestCustomEqualityRenderable(value: 1))
    }

    func testEqualityMutatedId() {
        expect(template) != Node(id: TestRowId.second,
                                 component: TestCustomEqualityRenderable(value: 0))
    }
}

private var template: Node<TestRowId> {
    return Node(id: TestRowId.first,
                component: TestCustomEqualityRenderable(value: 0))
}
