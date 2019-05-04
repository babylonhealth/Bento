@testable import Bento
import Nimble
import XCTest
import FlexibleDiff

private let size = CGSize(width: 100, height: 100)

class AdapterStoreItemTests: XCTestCase {
    func test_sized() {
        expect(Item.sized(size).size(allowEstimation: true)) == size
        expect(Item.sized(size).size(allowEstimation: false)) == size
    }

    func test_invalidated_with_old_size() {
        expect(Item.invalidated(size).size(allowEstimation: true)) == size
        expect(Item.invalidated(size).size(allowEstimation: false)).to(beNil())
    }

    func test_invalidated_with_no_size() {
        expect(Item.invalidated(nil).size(allowEstimation: true)).to(beNil())
        expect(Item.invalidated(nil).size(allowEstimation: false)).to(beNil())
    }
}
