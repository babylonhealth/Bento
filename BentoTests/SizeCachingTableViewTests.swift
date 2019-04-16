import XCTest
import UIKit
import Nimble
@testable import Bento

final class SizeCachingTableViewTests: XCTestCase {
    func test_it_creates_the_adapter_with_the_desired_type() {
        let view = SizeCachingTableView(frame: .zero, style: .plain, adapterClass: TestAdapter.self)
        expect(view.delegate).to(beAKindOf(TestAdapter.self))
        expect(view.dataSource).to(beAKindOf(TestAdapter.self))
    }
}

private class TestAdapter: TableViewAdapterBase<Int, Int>, UITableViewDataSource, UITableViewDelegate {}
