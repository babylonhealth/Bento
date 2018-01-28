import UIKit
import FormsKit

class ViewController: UIViewController {
    enum State {
        case airplaneMode
        case wifi(Bool)
    }

    enum SectionId: Hashable {
        case emptySection
    }

    enum RowId: Hashable {
        case space(CGFloat)
        case note(String)
        case toggle(String)

        var hashValue: Int {
            switch self {
            case .note(let id):
                return id.hashValue
            case .toggle(let id):
                return id.hashValue
            case .space(let height):
                return height.hashValue
            }
        }

        static func ==(lhs: ViewController.RowId, rhs: ViewController.RowId) -> Bool {
            switch (lhs, rhs) {
            case let (.note(lhsValue), .note(rhsValue)):
                return lhsValue == rhsValue
            case let (.toggle(lhsValue), .toggle(rhsValue)):
                return lhsValue == rhsValue
            case let (.space(lhsValue), .space(rhsValue)):
                return lhsValue == rhsValue
            default:
                return false
            }
        }
    }

    @IBOutlet weak var tableView: UITableView!

    private var state = State.airplaneMode {
        didSet {
            renderState()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        renderState()
    }

    private func renderState() {
        switch self.state {
        case .airplaneMode:
            let form = Form<SectionId, RowId>.empty
                |-+ ViewController.section()
                |--+ ViewController.toggle(id: "airplane",
                                           isOn: true,
                                           title: "Airplane mode",
                                           icon: #imageLiteral(resourceName:"plane"),
                                           onToggle: { isOn in
                                               if isOn {
                                                   self.state = State.airplaneMode
                                               } else {
                                                   self.state = State.wifi(true)
                                               }
                                           })
                |-+ ViewController.section()
                |--+ ViewController.toggle(id: "airplane",
                                           isOn: true,
                                           title: "Airplane mode",
                                           icon: #imageLiteral(resourceName:"plane"),
                                           onToggle: { isOn in
                                               if isOn {
                                                   self.state = State.airplaneMode
                                               } else {
                                                   self.state = State.wifi(true)
                                               }
                                           })
                |--+ ViewController.iconText(id: "wifi",
                                             icon: #imageLiteral(resourceName:"wifi"),
                                             text: "WIFI on")
        form.render(in: tableView)
        case .wifi:
            let form = Form<SectionId, RowId>.empty
                |-+ ViewController.section()
                |--+ ViewController.toggle(id: "airplane",
                                           isOn: false,
                                           title: "Airplane mode",
                                           icon: #imageLiteral(resourceName:"plane"),
                                           onToggle: { isOn in
                                               if isOn {
                                                   self.state = State.airplaneMode
                                               } else {
                                                   self.state = State.wifi(true)
                                               }
                                           })
                |--+ ViewController.iconText(id: "wifi",
                                             icon: #imageLiteral(resourceName:"wifi"),
                                             text: "WIFI OFF")
                |-+ ViewController.section()
                |--+ ViewController.toggle(id: "airplane",
                                           isOn: false,
                                           title: "Airplane mode",
                                           icon: #imageLiteral(resourceName:"plane"),
                                           onToggle: { isOn in
                                               if isOn {
                                                   self.state = State.airplaneMode
                                               } else {
                                                   self.state = State.wifi(true)
                                               }
                                           })
                |--+ ViewController.iconText(id: "wifi",
                                             icon: #imageLiteral(resourceName:"wifi"),
                                             text: "WIFI OFF")
        form.render(in: tableView)
        }
    }

    private func setupTableView() {
        tableView.estimatedSectionFooterHeight = 18
        tableView.estimatedSectionHeaderHeight = 18
        tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        tableView.sectionFooterHeight = UITableViewAutomaticDimension
    }

    private static func toggle(id: String,
                               isOn: Bool,
                               title: String? = nil,
                               icon: UIImage? = nil,
                               onToggle: ((Bool) -> Void)?) -> Node<RowId> {
        let component = ToggleComponent(isOn: isOn,
                                        title: title,
                                        icon: icon,
                                        onToggle: onToggle)
        return Node(id: RowId.toggle(id), component: component)
    }

    private static func iconText(id: String, icon: UIImage?, text: String?) -> Node<RowId> {
        let component = IconTextComponent(image: nil,
                                          title: text)

        return Node(id: RowId.note(id), component: component)
    }

    private static func section() -> Section<SectionId, RowId> {
        let headerComponent = EmptySpaceComponent(height: 30)
        let footerComponent = EmptySpaceComponent(height: 30)
        let headerNode = HeaderFooterNode(component: headerComponent)
        let footerNode = HeaderFooterNode(component: footerComponent)
        return Section(header: headerNode,
                       footer: footerNode)
    }
}
