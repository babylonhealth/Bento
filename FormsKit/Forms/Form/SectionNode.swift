import UIKit

public struct SectionNode {
    enum Rendering {
        case noSection
        case section(AnyRenderable)
    }
    
    let rendering: Rendering

    public init<R: Renderable>(component: R) {
        self.rendering = .section(AnyRenderable(renderable: component))
    }

    public init() {
        self.rendering = .noSection
    }

    public static var empty: SectionNode {
        return SectionNode()
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
