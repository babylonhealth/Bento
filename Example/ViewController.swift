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
        case space
        case note
        case toggle
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
                |--+ ViewController.toggle(isOn: true,
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
                |--+ ViewController.toggle(isOn: true,
                                           title: "Airplane mode",
                                           icon: #imageLiteral(resourceName:"plane"),
                                           onToggle: { isOn in
                                               if isOn {
                                                   self.state = State.airplaneMode
                                               } else {
                                                   self.state = State.wifi(true)
                                               }
                                           })
                |--+ ViewController.iconText(icon: #imageLiteral(resourceName:"wifi"),
                                             text: "WIFI OFF")
        form.render(in: tableView)
        case .wifi:
            let form = Form<SectionId, RowId>.empty
                |-+ ViewController.section()
                |--+ ViewController.toggle(isOn: false,
                                           title: "Airplane mode",
                                           icon: #imageLiteral(resourceName:"plane"),
                                           onToggle: { isOn in
                                               if isOn {
                                                   self.state = State.airplaneMode
                                               } else {
                                                   self.state = State.wifi(true)
                                               }
                                           })
                |--+ ViewController.iconText(icon: #imageLiteral(resourceName:"wifi"),
                                             text: "WIFI ON")
                |-+ ViewController.section()
                |--+ ViewController.toggle(isOn: false,
                                           title: "Airplane mode",
                                           icon: #imageLiteral(resourceName:"plane"),
                                           onToggle: { isOn in
                                               if isOn {
                                                   self.state = State.airplaneMode
                                               } else {
                                                   self.state = State.wifi(true)
                                               }
                                           })
                |--+ ViewController.iconText(icon: #imageLiteral(resourceName:"wifi"),
                                             text: "WIFI ON")
        form.render(in: tableView)
        }
    }

    private func setupTableView() {
        tableView.estimatedSectionFooterHeight = 18
        tableView.estimatedSectionHeaderHeight = 18
        tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        tableView.sectionFooterHeight = UITableViewAutomaticDimension
    }

    private static func toggle(isOn: Bool,
                               title: String? = nil,
                               icon: UIImage? = nil,
                               onToggle: ((Bool) -> Void)?) -> Node<RowId> {
        let component = ToggleComponent(isOn: isOn,
                                        title: title,
                                        icon: icon,
                                        onToggle: onToggle)
        return Node(id: RowId.toggle, component: component)
    }

    private static func iconText(icon: UIImage?, text: String?) -> Node<RowId> {
        let component = IconTextComponent(image: icon,
                                          title: text)

        return Node(id: RowId.note, component: component)
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
