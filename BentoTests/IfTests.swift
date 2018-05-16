import Nimble
import XCTest
import UIKit
@testable import Bento

class IfTests: XCTestCase {

    func testSectionConditionalTrueConcatentation() {
        let section = Section<TestSectionId, TestRowId>(id: .first)

        let box = Box<TestSectionId, TestRowId>.empty
            |-? If.iff(true, section)

        expect(box.sections.count) == 1
    }

    func testSectionConditionalTrueClosureConcatentation() {
        let section = Section<TestSectionId, TestRowId>(id: .first)

        let box = Box<TestSectionId, TestRowId>.empty
            |-? If.iff(true) {
                section
            }

        expect(box.sections.count) == 1
    }

    func testSectionConditionalFalseConcatentation() {
        let section = Section<TestSectionId, TestRowId>(id: .first)

        let box = Box<TestSectionId, TestRowId>.empty
            |-? If.iff(false, section)

        expect(box.sections.count) == 0
    }

    func testSectionConditionalFalseClosureConcatentation() {
        let section = Section<TestSectionId, TestRowId>(id: .first)

        let box = Box<TestSectionId, TestRowId>.empty
            |-? If.iff(false) {
                section
            }

        expect(box.sections.count) == 0
    }

    func testNodeConditionalTrueConcatenation() {
        let section = Section<TestSectionId, TestRowId>(id: .first)
        let node = Node(id: TestRowId.first,
                        component: TestCustomEqualityRenderable(value: 0))

        let result = section
            |---? If.iff(true, node)

        expect(result.rows.count) == 1
    }

    func testNodeConditionalTrueClosureConcatenation() {
        let section = Section<TestSectionId, TestRowId>(id: .first)
        let node = Node(id: TestRowId.first,
                        component: TestCustomEqualityRenderable(value: 0))

        let result = section
            |---? If.iff(true) {
                node
            }

        expect(result.rows.count) == 1
    }

    func testNodeConditionalFalseConcatenation() {
        let section = Section<TestSectionId, TestRowId>(id: .first)
        let node = Node(id: TestRowId.first,
                        component: TestCustomEqualityRenderable(value: 0))

        let result = section
            |---? If.iff(false, node)

        expect(result.rows.count) == 0
    }

    func testNodeConditionalFalseClosureConcatenation() {
        let section = Section<TestSectionId, TestRowId>(id: .first)
        let node = Node(id: TestRowId.first,
                        component: TestCustomEqualityRenderable(value: 0))

        let result = section
            |---? If.iff(false) {
                node
            }

        expect(result.rows.count) == 0
    }
}
