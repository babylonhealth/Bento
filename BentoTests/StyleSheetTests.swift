import XCTest
import UIKit
@testable import StyleSheets

class StyleSheetTests: XCTestCase {
    func test_application() {
        var view = View()

        let inverse = stub1.apply(to: &view)
        XCTAssert(view.banana == "🍌")
        XCTAssert(view.orange == "🍊")
        XCTAssert(view.apple == "🍎")

        let expectedInverse = StyleSheet<View>().with {
            $0.set(\.banana, "banana")
            $0.set(\.orange, "orange")
            $0.set(\.apple, "apple")
        }
        XCTAssert(inverse == expectedInverse)

        inverse.apply(to: &view)

        XCTAssert(view.banana == "banana")
        XCTAssert(view.orange == "orange")
        XCTAssert(view.apple == "apple")
    }

    func test_subscript_nilClearsRecordOfNonOptionalProperty() {
        var styleSheet = StyleSheet<View>()

        styleSheet.set(\.banana, "banana")
        XCTAssert(styleSheet.value(for: \.banana) == "banana")

        styleSheet.removeValue(for: \.banana)
        XCTAssert(styleSheet.value(for: \.banana) == nil)
    }

    func test_subscript_nilPopulatesRecordOfOptionalProperty() {
        var styleSheet = StyleSheet<View>()

        styleSheet.set(\.inbox, "banana")
        XCTAssert(styleSheet.value(for: \.inbox) == "banana")

        styleSheet.set(\.inbox, nil)
        XCTAssert(styleSheet.value(for: \.inbox) == .some(.none))

        styleSheet.removeValue(for: \.inbox)
        XCTAssert(styleSheet.value(for: \.inbox) == nil)
    }

    func test_equality_emptyInstanceIsEqual() {
        XCTAssert(StyleSheet<View>() == StyleSheet<View>())
    }

    func test_equality_sameInstanceIsEqual() {
        XCTAssert(stub1 == stub1)
    }

    func test_equality_immutableCopiesAreEqual() {
        let localStub = stub1
        XCTAssert(localStub == stub1)
        XCTAssert(stub1 == localStub)
    }

    func test_equality_addingNewEntryMakesItUnequal() {
        let changed = stub1.setting(\.eggplant, "🍆")
        XCTAssert(changed != stub1)
        XCTAssert(stub1 != changed)
    }

    func test_equality_removingExistingEntryMakesItUnequal() {
        let changed = stub1.with { $0.removeValue(for: \.banana) }
        XCTAssert(changed != stub1)
        XCTAssert(stub1 != changed)
    }

    func test_equality_changingExistingEntryMakesItUnequal() {
        let changed = stub1.setting(\.orange, "🥕🍊🧡")
        XCTAssert(changed != stub1)
        XCTAssert(stub1 != changed)
    }

    func test_equality_repopulatingTheSameValuesShouldBeEqual() {
        let changed = stub1.with {
            $0.removeValue(for: \.banana)
            $0.removeValue(for: \.orange)
            $0.removeValue(for: \.apple)
        }

        XCTAssert(changed != stub1)

        let changed2 = changed.with {
            $0.set(\.banana, "🍌")
            $0.set(\.orange, "🍊")
            $0.set(\.apple, "🍎")
        }

        XCTAssert(changed2 == stub1)
    }
}

struct View {
    var banana = "banana"
    var orange = "orange"
    var apple = "apple"
    var eggplant = "eggplant"

    var inbox: String? = nil
}

private let stub1 = StyleSheet<View>().with {
    $0.set(\.banana, "🍌")
    $0.set(\.orange, "🍊")
    $0.set(\.apple, "🍎")
}
