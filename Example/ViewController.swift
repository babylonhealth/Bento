import UIKit
import FormsKit

class ViewController: UIViewController {
    enum State {
        case airplaneMode
        case wifi(Bool)
    }

    enum ComponentId: Hashable {
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

        static func ==(lhs: ViewController.ComponentId, rhs: ViewController.ComponentId) -> Bool {
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
    private lazy var dataSource = FormTableViewDataSource<ComponentId>(for: self.tableView)

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
            let builder = FormBuilder<ComponentId>.empty
                |-+ ViewController.space(30)
                |-+ ViewController
                    .toggle(id: "airplane",
                            isOn: true,
                            title: "Airplane mode",
                            icon: #imageLiteral(resourceName: "plane"),
                            onToggle: { isOn in
                                if isOn {
                                    self.state = State.airplaneMode
                                } else {
                                    self.state = State.wifi(true)
                                }
                    })
                |-+ ViewController.space(30)
                |-+ ViewController.iconText(id: "wifi",
                                            icon: #imageLiteral(resourceName: "wifi"),
                                            text: "WIFI on")
                |-+ ViewController.iconText(id: "wifi1",
                                            icon: #imageLiteral(resourceName: "wifi"),
                                            text: "WIFI on")

            dataSource.update(with: builder.build())
        case .wifi:
            let builder = FormBuilder<ComponentId>.empty
                |-+ ViewController.space(30)
                |-+ ViewController
                    .toggle(id: "airplane",
                            isOn: false,
                            title: "Airplane mode",
                            icon: #imageLiteral(resourceName: "plane"),
                            onToggle: { isOn in
                                if isOn {
                                    self.state = State.airplaneMode
                                } else {
                                    self.state = State.wifi(true)
                                }
                    })
                |-+ ViewController.iconText(id: "wifi",
                                            icon: #imageLiteral(resourceName: "wifi"),
                                            text: "WIFI OFF")

            dataSource.update(with: builder.build())
        }
    }

    private func setupTableView() {
        self.tableView.dataSource = dataSource
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableViewAutomaticDimension
    }

    private static func space(_ height: CGFloat) -> FormItem<ComponentId> {
        return FormItem(id: ComponentId.space(height),
                        component: EmptySpaceComponent(height: height))
    }

    private static func toggle(id: String,
                               isOn: Bool,
                               title: String? = nil,
                               icon: UIImage? = nil,
                               onToggle: ((Bool) -> Void)?) -> FormItem<ComponentId> {
        let component = ToggleComponent(isOn: isOn,
                                        title: title,
                                        icon: icon,
                                        onToggle: onToggle)
        return FormItem(id: ComponentId.toggle(id), component: component)
    }

    private static func iconText(id: String, icon: UIImage?, text: String?) -> FormItem<ComponentId> {
        let component = IconTextComponent(image: nil,
                                          title: text)

        return FormItem(id: ComponentId.note(id), component: component)
    }
}
