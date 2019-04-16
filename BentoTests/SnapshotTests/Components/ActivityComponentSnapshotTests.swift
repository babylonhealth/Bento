import Bento
import StyleSheets

final class ActivityComponentSnapshotTests: SnapshotTestCase {
    override func setUp() {
        super.setUp()
        self.recordMode = false
    }

    func test_loading_default_style() {
        let component = Component.Activity(isLoading: true)

        verifyComponentForAllSizes(component: component)
    }
}
