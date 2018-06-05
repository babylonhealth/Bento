import Nimble
import XCTest
import UIKit
@testable import Bento

import XCTest

class RenderableTests: XCTestCase {
    
    func testReuseIdentifierWithoutNameCollisions() {
        expect(Component.Text().reuseIdentifier) != Component.Image().reuseIdentifier
    }
}

enum Component {}

extension Component {

    final class Text: Renderable {
        func render(in view: View) {}
    }
}

extension Component.Text {

    public final class View: UIView {}
}

extension Component {

    final class Image: Renderable {

        func render(in view: View) {}
    }
}

extension Component.Image {

    public final class View: UIView {}
}
