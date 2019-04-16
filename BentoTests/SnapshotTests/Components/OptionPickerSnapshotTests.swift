import XCTest
import Bento
import StyleSheets

final class OptionPickerSnapshotTests: SnapshotTestCase {
    override func setUp() {
        super.setUp()
        self.recordMode = false
    }

    func test_default() {
        let items = [
            "Hello",
            "This is a very long option string, really, really, really long",
            "Be the change you want to see in the world",
            "Don't be Evil",
            "Review your peers"
        ]
        let component = Component.OptionPicker(options: items, selected: nil)

        verifyComponentForAllSizes(component: component)
    }
}

extension String: Option {
    public var displayName: String {
        return self
    }
}

