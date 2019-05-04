import XCTest
import UIKit
import Nimble
@testable import Bento

class StyleSheetTests: XCTestCase {
    func test_application() {
        var view = View()

        let inverse = stub1.apply(to: &view)
        expect(view.banana) == "🍌"
        expect(view.orange) == "🍊"
        expect(view.apple) == "🍎"

        let expectedInverse = StyleSheet<View>().with {
            // NOTE: The order should be reversed with regard to `stub1`.
            $0.set(\.apple, "apple")
            $0.set(\.orange, "orange")
            $0.set(\.banana, "banana")
        }
        expect(inverse) == expectedInverse

        inverse.apply(to: &view)

        expect(view.banana) == "banana"
        expect(view.orange) == "orange"
        expect(view.apple) == "apple"
    }

    func test_subscript_nilClearsRecordOfNonOptionalProperty() {
        var styleSheet = StyleSheet<View>()

        styleSheet.set(\.banana, "banana")
        expect(styleSheet.value(for: \.banana)) == "banana"

        styleSheet.removeValue(for: \.banana)
        expect(styleSheet.value(for: \.banana)).to(beNil())
    }

    func test_subscript_nilPopulatesRecordOfOptionalProperty() {
        var styleSheet = StyleSheet<View>()

        styleSheet.set(\.inbox, "banana")
        expect(styleSheet.value(for: \.inbox)) == "banana"

        styleSheet.set(\.inbox, nil)
        expect(styleSheet.value(for: \.inbox)) == .some(.none)

        styleSheet.removeValue(for: \.inbox)
        expect(styleSheet.value(for: \.inbox)).to(beNil())
    }

    func test_equality_emptyInstanceIsEqual() {
        expect(StyleSheet<View>()) == StyleSheet<View>()
    }

    func test_equality_sameInstanceIsEqual() {
        expect(stub1) == stub1
    }

    func test_equality_immutableCopiesAreEqual() {
        let localStub = stub1
        expect(localStub) == stub1
        expect(stub1) == localStub
    }

    func test_equality_addingNewEntryMakesItUnequal() {
        let changed = stub1.setting(\.eggplant, "🍆")
        expect(changed) != stub1
        expect(stub1) != changed
    }

    func test_equality_removingExistingEntryMakesItUnequal() {
        let changed = stub1.with { $0.removeValue(for: \.banana) }
        expect(changed) != stub1
        expect(stub1) != changed
    }

    func test_equality_changingExistingEntryMakesItUnequal() {
        let changed = stub1.setting(\.orange, "🥕🍊🧡")
        expect(changed) != stub1
        expect(stub1) != changed
    }

    func test_equality_repopulatingTheSameValuesShouldBeEqual() {
        let changed = stub1.with {
            $0.removeValue(for: \.banana)
            $0.removeValue(for: \.orange)
            $0.removeValue(for: \.apple)
        }

        expect(changed) != stub1

        let changed2 = changed.with {
            $0.set(\.banana, "🍌")
            $0.set(\.orange, "🍊")
            $0.set(\.apple, "🍎")
        }

        expect(changed2) == stub1
    }

    func test_application_same_keypath_set_repeatedly_with_different_values() {
        var styleSheet = StyleSheet<View>()

        styleSheet.set(\.banana, "banana")
        styleSheet.set(\.banana, "not banana")
        styleSheet.set(\.banana, "probably banana")
        expect(styleSheet.value(for: \.banana)) == "probably banana"

        var view = View()
        let snapshot = styleSheet.apply(to: &view)
        expect(view.banana) == "probably banana"
        expect(snapshot.value(for: \.banana)) == "banana"

        let snapshot2 = snapshot.apply(to: &view)
        expect(view.banana) == "banana"
        expect(styleSheet) == snapshot2
    }

    func test_application_partially_overlapping_keyPaths_1() {
        var view = View()

        let original = StyleSheet<View>().with {
            $0.set(\.nested, View.Nested(red: "$R", orange: "$O"))
            $0.set(\.nested.red, "🔴")
            $0.set(\.nested.orange, "🔶")
        }

        let inverse = original.apply(to: &view)
        expect(view.nested) == View.Nested(red: "🔴", orange: "🔶")

        let expectedInverse = StyleSheet<View>().with {
            $0.set(\.nested.orange, "$O")
            $0.set(\.nested.red, "$R")
            $0.set(\.nested, View.Nested(red: "red", orange: "orange"))
        }
        expect(inverse) == expectedInverse

        inverse.apply(to: &view)

        expect(view.nested) == View.Nested(red: "red", orange: "orange")
    }

    func test_application_partially_overlapping_keyPaths_2() {
        var view = View()

        let original = StyleSheet<View>().with {
            $0.set(\.nested.red, "🔴")
            $0.set(\.nested.orange, "🔶")
            $0.set(\.nested, View.Nested(red: "$R", orange: "$O"))
        }

        let inverse = original.apply(to: &view)
        expect(view.nested) == View.Nested(red: "$R", orange: "$O")

        let expectedInverse = StyleSheet<View>().with {
            $0.set(\.nested, View.Nested(red: "🔴", orange: "🔶"))
            $0.set(\.nested.orange, "orange")
            $0.set(\.nested.red, "red")
        }
        expect(inverse) == expectedInverse

        inverse.apply(to: &view)

        expect(view.nested) == View.Nested(red: "red", orange: "orange")
    }
}

struct View {
    var banana = "banana"
    var orange = "orange"
    var apple = "apple"
    var eggplant = "eggplant"

    var inbox: String? = nil

    var nested = Nested()

    struct Nested: Equatable {
        var red: String
        var orange: String

        init(red: String = "red", orange: String = "orange") {
            self.red = red
            self.orange = orange
        }
    }
}

private let stub1 = StyleSheet<View>().with {
    $0.set(\.banana, "🍌")
    $0.set(\.orange, "🍊")
    $0.set(\.apple, "🍎")
}
