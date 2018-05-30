import Bento
import UIKit

class ViewController: UIViewController {
    enum State {
        case airplaneMode
        case wifi
    }

    enum SectionId: Hashable {
        case first
        case second
    }

    enum RowId: Hashable {
        case space
        case note
        case toggle
        case statefulToggle
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
        switch state {
        case .airplaneMode:
            let box = Box<SectionId, RowId>.empty
                |-+ renderFirstSection()
                |---+ renderToggle()
                |---+ renderIconText()
                |-+ renderSecondSection()
                |---+ renderIconText()
                |---+ renderStatefullToggle()

            tableView.render(box)
        case .wifi:
            let box = Box<SectionId, RowId>.empty
                |-+ renderFirstSection()
                |---+ renderIconText()
                |---+ renderToggle()
                |-+ renderSecondSection()
                |---+ renderToggle()
                |---+ renderIconText()

            tableView.render(box)
        }
    }

    private func setupTableView() {
        tableView.estimatedSectionFooterHeight = 18
        tableView.estimatedSectionHeaderHeight = 18
        tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        tableView.sectionFooterHeight = UITableViewAutomaticDimension
    }

    private func renderFirstSection() -> Section<SectionId, RowId> {
        switch state {
        case .airplaneMode:
            let headerSpec = EmptySpaceComponent.Spec(height: 20, color: .black)
            let footerSpec = EmptySpaceComponent.Spec(height: 20, color: .cyan)
            let headerComponent = EmptySpaceComponent(spec: headerSpec)
            let footerComponent = EmptySpaceComponent(spec: footerSpec)

            return Section(id: SectionId.first, header: headerComponent, footer: footerComponent)
        case .wifi:
            let footerSpec = EmptySpaceComponent.Spec(height: 100, color: .green)
            let footerComponent = EmptySpaceComponent(spec: footerSpec)
            return Section(id: SectionId.first, footer: footerComponent)
        }
    }

    private func renderSecondSection() -> Section<SectionId, RowId> {
        switch state {
        case .airplaneMode:
            let headerSpec = EmptySpaceComponent.Spec(height: 20, color: .orange)
            let footerSpec = EmptySpaceComponent.Spec(height: 20, color: .yellow)
            let headerComponent = EmptySpaceComponent(spec: headerSpec)
            let footerComponent = EmptySpaceComponent(spec: footerSpec)

            return Section(id: SectionId.first, header: headerComponent, footer: footerComponent)
        case .wifi:
            let headerSpec = EmptySpaceComponent.Spec(height: 30, color: .purple)
            let headerComponent = EmptySpaceComponent(spec: headerSpec)
            return Section(id: SectionId.first, header: headerComponent)
        }
    }

    private func renderToggle() -> Node<RowId> {
        let component = ToggleComponent(isOn: self.state == .airplaneMode,
                                        title: "Airplane mode",
                                        icon: #imageLiteral(resourceName:"plane"),
                                        onToggle: { isOn in
                                            if isOn {
                                                self.state = State.airplaneMode
                                            } else {
                                                self.state = State.wifi
                                            }
                                        })
        return RowId.toggle <> component
    }
    
    func renderStatefullToggle() -> Node<RowId> {
        let component = StatefulToggle(isOn: self.state == .airplaneMode,
                                       title: "Stateful Toggle",
                                       icon: #imageLiteral(resourceName:"plane"))

        return .statefulToggle <> component
    }

    private func renderIconText() -> Node<RowId> {
        switch state {
        case .airplaneMode:
            return RowId.note <> IconTextComponent(image: #imageLiteral(resourceName: "wifi"), title: "WIFI Off")
        case .wifi:
            return RowId.note <> IconTextComponent(image: #imageLiteral(resourceName: "wifi"), title: "WIFI On")
        }
    }
}
