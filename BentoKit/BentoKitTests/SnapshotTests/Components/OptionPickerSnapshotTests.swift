import XCTest
import BentoKit
import StyleSheets

final class OptionPickerSnapshotTests: SnapshotTestCase {
    override func setUp() {
        super.setUp()
        self.recordMode = false
    }

    func test_default() {
        let items = Array(repeating: "Hello", count: 5)
        let component = Component.OptionPicker(options: items, selected: nil)

        verifyComponentForAllSizes(component: component)
    }
}

extension String: Option {
    public var displayName: String {
        return self
    }
}

