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

    func testSectionOptionalConcatentation() {
        let box = Box<TestSectionId, TestRowId>.empty
            |-+ nil

        expect(box.sections.count) == 0
    }

    func testNodeConcatenation() {
        let section = Section<TestSectionId, TestRowId>(id: .first)
        let node = Node(id: TestRowId.first,
                        component: TestCustomEqualityRenderable(value: 0))

        let result = section
            |---+ node

        expect(result.rows.count) == 1
    }

    func testNodeOptionalConcatenation() {
        let section = Section<TestSectionId, TestRowId>(id: .first)

        let result: Section<TestSectionId, TestRowId> = section
            |---+ nil

        expect(result.rows.count) == 0
    }
}
