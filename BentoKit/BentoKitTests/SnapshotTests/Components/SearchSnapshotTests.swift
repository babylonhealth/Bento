import BentoKit
import StyleSheets
import UIKit
@testable import BentoKitPlaygroundSupport

final class SearchSnapshotTests: SnapshotTestCase {
    let placeholder = "Search for address or a postcode"

    override func setUp() {
        super.setUp()
        self.recordMode = false
    }

    func testSearch() {
        let styleSheet = Component.Search.StyleSheet()
            .compose(\.searchBar.backgroundColor, UIColor.gray.withAlphaComponent(0.25))
            .compose(\.searchBar.showsCancelButton, true)

        let component = Component.Search(placeholder: placeholder, styleSheet: styleSheet)

        verifyComponentForAllSizes(component: component)
    }

}
