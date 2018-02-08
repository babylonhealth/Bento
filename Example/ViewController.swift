import UIKit
import FormsKit

class ViewController: UIViewController {
    enum State {
        case airplaneMode
        case wifi(Bool)
    }

    enum SectionId: Hashable {
        case first
        case second
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
        case .wifi:
            let form = Form<SectionId, RowId>.empty
                |-+ ViewController.section(id: .first,
                                           headerSpec: EmptySpaceComponent.Spec(height: 40, color: .red),
                                           footerSpec: EmptySpaceComponent.Spec(height: 100, color: .green))
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
                                             text: "WIFI On")
                |-+ ViewController.section(id: .second,
                                           headerSpec: EmptySpaceComponent.Spec(height: 30, color: .purple),
                                           footerSpec: EmptySpaceComponent.Spec(height: 50, color: .magenta))
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
                                             text: "WIFI On")

            form.render(in: tableView)
        case .airplaneMode:
            let form = Form<SectionId, RowId>.empty
                |-+ ViewController.section(id: .first,
                                           headerSpec: EmptySpaceComponent.Spec(height: 20, color: .black),
                                           footerSpec: EmptySpaceComponent.Spec(height: 20, color: .cyan))
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
                |-+ ViewController.section(id: .second,
                                           headerSpec: EmptySpaceComponent.Spec(height: 20, color: .orange),
                                           footerSpec: EmptySpaceComponent.Spec(height: 20, color: .yellow))
                |--+ ViewController.iconText(icon: #imageLiteral(resourceName:"wifi"),
                                             text: "WIFI Off")
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

    private static func section(id: SectionId,
                                headerSpec: EmptySpaceComponent.Spec,
                                footerSpec: EmptySpaceComponent.Spec) -> Section<SectionId, RowId> {
        let headerComponent = EmptySpaceComponent(spec: headerSpec)
        let footerComponent = EmptySpaceComponent(spec: footerSpec)
        return Section(id: id,
                       header: headerComponent,
                       footer: footerComponent)
    }
}
