import Nimble
import XCTest
import UIKit
@testable import Bento

class ConcatenationTests: XCTestCase {

    func testSectionConcatentation() {
        let section = Section<TestSectionId, TestRowId>(id: .first)

        let box = Box<TestSectionId, TestRowId>.empty
            |-+ section

        expect(box.sections.count) == 1
    }

    func testSectionOptionalNilConcatentation() {
        let section = Section<TestSectionId, TestRowId>(id: .first)
        let optional: String? = nil

        let box = Box<TestSectionId, TestRowId>.empty
            |-? .some(optional) { _ in
                section
            }

        expect(box.sections.count) == 0
    }

    func testSectionOptionalSomeConcatentation() {
        let section = Section<TestSectionId, TestRowId>(id: .first)
        let optional: String? = "something"

        let box = Box<TestSectionId, TestRowId>.empty
            |-? .some(optional) { _ in
                section
            }

        expect(box.sections.count) == 1
    }

    func testNodeConcatenation() {
        let section = Section<TestSectionId, TestRowId>(id: .first)
        let node = Node(id: TestRowId.first,
                        component: TestCustomEqualityRenderable(value: 0))

        let result = section
            |---+ node

        expect(result.items.count) == 1
    }

    func testNodeOptionalNilConcatenation() {
        let section = Section<TestSectionId, TestRowId>(id: .first)
        let node = Node(id: TestRowId.first,
                        component: TestCustomEqualityRenderable(value: 0))
        let optional: String? = nil

        let result: Section<TestSectionId, TestRowId> = section
            |---? .some(optional) { _ in
                node
            }

        expect(result.items.count) == 0
    }

    func testNodeOptionalSomeConcatenation() {
        let section = Section<TestSectionId, TestRowId>(id: .first)
        let node = Node(id: TestRowId.first,
                        component: TestCustomEqualityRenderable(value: 0))
        let optional: String? = "something"

        let result: Section<TestSectionId, TestRowId> = section
            |---? .some(optional) { _ in
                node
            }

        expect(result.items.count) == 1
    }
}
