import UIKit

public struct SectionNode<Identifier: Hashable> {
    enum Rendering {
        case noSection
        case section(AnyRenderable)
    }

    let id: Identifier?
    let rendering: Rendering

    public init<R: Renderable>(id: Identifier? = nil, component: R) {
        self.id = id
        self.rendering = .section(AnyRenderable(renderable: component))
    }

    public init(id: Identifier? = nil) {
        self.id = id
        self.rendering = .noSection
    }

    public static var empty: SectionNode<Identifier> {
        return SectionNode(id: nil)
    }

    func render(in tableView: UITableView, for section: Int) -> UIView? {
        switch rendering {
        case .noSection:
            return nil
        case let .section(renderable):
            return renderable.renderHeaderFooter(in: tableView, for: section)
        }
    }
}
