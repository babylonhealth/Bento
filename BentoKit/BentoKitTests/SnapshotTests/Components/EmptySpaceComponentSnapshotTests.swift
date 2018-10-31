import XCTest
import StyleSheets
import BentoKit

final class EmptyComponentSnapshotTests: SnapshotTestCase {
    override func setUp() {
        super.setUp()
        self.recordMode = false
    }

    func test_with_height_44() {
        let component = Component.EmptySpace(
            height: 44,
            styleSheet: ViewStyleSheet()
                .compose(\.backgroundColor, .purple)
        )

        verifyComponentForAllSizes(component: component)
    }

    func test_with_height_22() {
        let component = Component.EmptySpace(
            height: 22,
            styleSheet: ViewStyleSheet()
            .compose(\.backgroundColor, .green)
        )

        verifyComponentForAllSizes(component: component)
    }

}

