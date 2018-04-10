import UIKit
@testable import Bento

struct TestCustomEqualityRenderable: Renderable {
    typealias View = UIView

    let value: Int

    func render(in view: UIView) {}

    static func == (lhs: TestCustomEqualityRenderable, rhs: TestCustomEqualityRenderable) -> Bool {
        return lhs.value == rhs.value
    }
}

final class TestDefaultEqualityRenderable: Renderable {
    typealias View = UIView

    func render(in view: UIView) {}
}
