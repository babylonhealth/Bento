import Nimble
import XCTest
import UIKit
@testable import Bento

class SectionTests: XCTestCase {
    func testMetadataEqualitySelfEquality() {
        expect(Section.hasEqualMetadata(template, template)) == true
    }

    func testMetadataEqualityDifferentFooter() {
        let section = Section<TestSectionId, TestRowId>(
            id: TestSectionId.first,
            header: TestCustomEqualityRenderable(value: 0),
            footer: TestCustomEqualityRenderable(value: 2),
            items: []
        )

        expect(Section.hasEqualMetadata(section, section)) == true
        expect(Section.hasEqualMetadata(template, section)) == false
    }

    func testMetadataEqualityDifferentHeader() {
        let section = Section<TestSectionId, TestRowId>(
            id: TestSectionId.first,
            header: TestCustomEqualityRenderable(value: -1),
            footer: TestCustomEqualityRenderable(value: 1),
            items: []
        )

        expect(Section.hasEqualMetadata(section, section)) == true
        expect(Section.hasEqualMetadata(template, section)) == false
    }

    func testMetadataEqualityDifferentHeaderType() {
        let section = Section<TestSectionId, TestRowId>(
            id: TestSectionId.first,
            header: TestDefaultEqualityRenderable(),
            footer: TestCustomEqualityRenderable(value: 1),
            items: []
        )

        expect(Section.hasEqualMetadata(section, section)) == true
        expect(Section.hasEqualMetadata(template, section)) == false
    }

    func testMetadataEqualityDifferentFooterType() {
        let section = Section<TestSectionId, TestRowId>(
            id: TestSectionId.first,
            header: TestCustomEqualityRenderable(value: 0),
            footer: TestDefaultEqualityRenderable(),
            items: []
        )

        expect(Section.hasEqualMetadata(section, section)) == true
        expect(Section.hasEqualMetadata(template, section)) == false
    }

    func testMetadataEqualityOmittedFooter() {
        let section = Section<TestSectionId, TestRowId>(
            id: TestSectionId.first,
            header: TestCustomEqualityRenderable(value: 0),
            items: []
        )

        expect(Section.hasEqualMetadata(section, section)) == true
        expect(Section.hasEqualMetadata(template, section)) == false
    }

    func testMetadataEqualityOmittedHeader() {
        let section = Section<TestSectionId, TestRowId>(
            id: TestSectionId.first,
            footer: TestCustomEqualityRenderable(value: 1),
            items: []
        )

        expect(Section.hasEqualMetadata(section, section)) == true
        expect(Section.hasEqualMetadata(template, section)) == false
    }

    func testEqualitySelfEquality() {
        expect(templateWithNodes) == templateWithNodes
    }

    func testEqualityMutatedFooter() {
        let section = Section<TestSectionId, TestRowId>(
            id: TestSectionId.first,
            header: TestCustomEqualityRenderable(value: 0),
            footer: TestCustomEqualityRenderable(value: .max),
            items: [Node(id: .first, component: TestCustomEqualityRenderable(value: 3))]
        )

        expect(section) == section
        expect(templateWithNodes) != section
    }

    func testEqualityMutatedHeader() {
        let section = Section<TestSectionId, TestRowId>(
            id: TestSectionId.first,
            header: TestCustomEqualityRenderable(value: .max),
            footer: TestCustomEqualityRenderable(value: 1),
            items: [Node(id: .first, component: TestCustomEqualityRenderable(value: 3))]
        )

        expect(section) == section
        expect(templateWithNodes) != section
    }

    func testEqualityMutatedNodes() {
        let section = Section<TestSectionId, TestRowId>(
            id: TestSectionId.first,
            header: TestCustomEqualityRenderable(value: .max),
            footer: TestCustomEqualityRenderable(value: 1),
            items: [Node(id: .first, component: TestCustomEqualityRenderable(value: 3)),
                   Node(id: .second, component: TestCustomEqualityRenderable(value: 3))]
        )

        expect(section) == section
        expect(templateWithNodes) != section
    }


    func testEqualityMutatedFooterWithDifferentComponentType() {
        let section = Section<TestSectionId, TestRowId>(
            id: TestSectionId.first,
            header: TestCustomEqualityRenderable(value: 0),
            footer: TestDefaultEqualityRenderable(),
            items: [Node(id: .first, component: TestCustomEqualityRenderable(value: 3))]
        )

        expect(section) == section
        expect(templateWithNodes) != section
    }

    func testEqualityMutatedHeaderWithDifferentComponentType() {
        let section = Section<TestSectionId, TestRowId>(
            id: TestSectionId.first,
            header: TestDefaultEqualityRenderable(),
            footer: TestCustomEqualityRenderable(value: 1),
            items: [Node(id: .first, component: TestCustomEqualityRenderable(value: 3))]
        )

        expect(section) == section
        expect(templateWithNodes) != section
    }

    func testEqualityMutatedNodesWithDifferentComponentType() {
        let section = Section<TestSectionId, TestRowId>(
            id: TestSectionId.first,
            header: TestCustomEqualityRenderable(value: .max),
            footer: TestCustomEqualityRenderable(value: 1),
            items: [Node(id: .first, component: TestDefaultEqualityRenderable())]
        )

        expect(section) == section
        expect(templateWithNodes) != section
    }

    func testEqualityOmittedFooter() {
        let section = Section<TestSectionId, TestRowId>(
            id: TestSectionId.first,
            header: TestCustomEqualityRenderable(value: 0),
            items: [Node(id: .first, component: TestCustomEqualityRenderable(value: 3))]
        )

        expect(section) == section
        expect(templateWithNodes) != section
    }

    func testEqualityOmittedHeader() {
        let section = Section<TestSectionId, TestRowId>(
            id: TestSectionId.first,
            footer: TestCustomEqualityRenderable(value: 1),
            items: [Node(id: .first, component: TestCustomEqualityRenderable(value: 3))]
        )

        expect(section) == section
        expect(templateWithNodes) != section
    }

    func testEqualityOmittedHeaderFooter() {
        let section = Section<TestSectionId, TestRowId>(
            id: TestSectionId.first,
            items: [Node(id: .first, component: TestCustomEqualityRenderable(value: 3))]
        )

        expect(section) == section
        expect(templateWithNodes) != section
    }

    func testEqualityOmittedNodes() {
        let section = Section<TestSectionId, TestRowId>(
            id: TestSectionId.second,
            header: TestCustomEqualityRenderable(value: 0),
            footer: TestCustomEqualityRenderable(value: 1),
            items: []
        )

        expect(section) == section
        expect(templateWithNodes) != section
    }
}

private var template: Section<TestSectionId, TestRowId> {
    return Section<TestSectionId, TestRowId>(
        id: TestSectionId.first,
        header: TestCustomEqualityRenderable(value: 0),
        footer: TestCustomEqualityRenderable(value: 1),
        items: []
    )
}

private var templateWithNodes: Section<TestSectionId, TestRowId> {
    return Section<TestSectionId, TestRowId>(
        id: TestSectionId.first,
        header: TestCustomEqualityRenderable(value: 0),
        footer: TestCustomEqualityRenderable(value: 1),
        items: [Node(id: .first, component: TestCustomEqualityRenderable(value: 3))]
    )
}
