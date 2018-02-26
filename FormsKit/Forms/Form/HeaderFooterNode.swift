import UIKit

struct HeaderFooterNode: Equatable {
    let component: AnyRenderable

    init<R: Renderable>(component: R) {
        self.component = AnyRenderable(renderable: component)
    }

    static func ==(lhs: HeaderFooterNode, rhs: HeaderFooterNode) -> Bool {
        return lhs.component === rhs.component
    }
}
