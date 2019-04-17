import Bento
import BentoKit
import FBSnapshotTestCase
import UIKit

extension FBSnapshotTestCase {
    static let tolerance: CGFloat = 0.01

    public func verify(
        viewController: UIViewController,
        for device: Device,
        customSize: CGSize? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        UIView.performWithoutAnimation {
            let window = HostWindow(screen: device)
            window.frame.size = customSize ?? device.size
            UIView.setAnimationsEnabled(false)
            window.rootViewController = viewController
            window.isHidden = false
            FBSnapshotVerifyView(window, identifier: device.indentifier, tolerance: FBSnapshotTestCase.tolerance, file: file, line: line)
        }
    }

    public func verifyComponentForAllSizes<R: Renderable>(
        component: R,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        testViewForAllSizes(
            view: self.render(component: component, in: UITableView(frame: .zero, style: .plain)),
            file: file,
            line: line
        )
    }

    public func verifyBoxForAllSizes<SectionId, RowId>(
        box: Box<SectionId, RowId>,
        style: UITableView.Style = .plain,
        separatorStyle: UITableViewCell.SeparatorStyle = .none,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let tableView = UITableView(frame: .zero, style: style)
        tableView.separatorStyle = separatorStyle

        let adapter = BoxTableViewAdapter<SectionId, RowId>(with: tableView)
        tableView.prepareForBoxRendering(with: adapter)
        tableView.render(box)
        testViewForAllSizes(view: tableView, file: file, line: line)
    }

    func testViewForAllSizes(view: UIView, file: StaticString = #file, line: UInt = #line) {
        for screen in Device.all {
            view.frame.size = screen.size
            FBSnapshotVerifyView(view, identifier: screen.indentifier, tolerance: FBSnapshotTestCase.tolerance, file: file, line: line)
        }
    }

    private func render<R: Renderable>(component: R, in tableView: UITableView) -> UITableView {
        let box = Box<Int, Int>.empty
            |-+ Section(id: 0)
            |---+ Node(id: 0, component: component)

        let adapter = BoxTableViewAdapter<Int, Int>(with: tableView)
        tableView.prepareForBoxRendering(with: adapter)
        tableView.render(box)

        return tableView
    }

    public func image(named: String) -> UIImage {
        return UIImage(named: named, in: Bundle(for: self.classForCoder), compatibleWith: nil)!
    }
}

open class SnapshotTestCase: FBSnapshotTestCase {
    open override func setUp() {
        super.setUp()
        Swift.assert(UIScreen.main.scale == 2, "You should run snapshot tests on 2x scale devices")
    }
}

fileprivate extension UIView {
    func pinInParent(to edges: [Edge]) {
        guard let parent = self.superview else {
            fatalError()
        }
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(edges.map { $0.constraintBetween(lhs: parent, rhs: self) })
    }
}

enum Edge {
    case top
    case leading
    case trailing
    case bottom

    static var all: [Edge] {
        return [.top, .leading, .trailing, .bottom]
    }

    func constraintBetween(lhs: UIView, rhs: UIView) -> NSLayoutConstraint {
        switch self {
        case .top:
            return lhs.topAnchor.constraint(equalTo: rhs.topAnchor)
        case .leading:
            return lhs.leadingAnchor.constraint(equalTo: rhs.leadingAnchor)
        case .trailing:
            return lhs.trailingAnchor.constraint(equalTo: rhs.trailingAnchor)
        case .bottom:
            return lhs.bottomAnchor.constraint(equalTo: rhs.bottomAnchor)
        }
    }
}
