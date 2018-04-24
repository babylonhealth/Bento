import UIKit
import Bento

extension UIViewController { //5
    @objc func injectedReload() {
        for subview in self.view.subviews { //3
            subview.removeFromSuperview()
        }
        
        viewDidLoad() //4
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
}

class InjectableViewController: UIViewController {
    private static let injectNotificationName = NSNotification.Name(rawValue: "INJECTION_BUNDLE_NOTIFICATION")
    private var observer: Any!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        observer = NotificationCenter.default
            .addObserver(forName: InjectableViewController.injectNotificationName,
                         object: nil,
                         queue: OperationQueue.main) { _ in
                            self.injectedReload()
            }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(observer)
    }
}

extension UIView {
    public func add(to container: UIView) -> Self {
        container.addSubview(self)
        return self
    }
    
    public func pinEdges(to view: UIView) {
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomAnchor.constraint(equalTo: view.bottomAnchor),
            trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topAnchor.constraint(equalTo: view.topAnchor)
            ])
    }
    
    public func pinEdges(to layoutGuide: UILayoutGuide, insets: UIEdgeInsets = .zero) {
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: layoutGuide.topAnchor, constant: insets.top),
            bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor, constant: insets.bottom),
            leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor, constant: insets.left),
            trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor, constant: insets.right)
            ])
    }
}

class ViewController: InjectableViewController {
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
    }

    private let tableView = UITableView(frame: .zero)

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
    
    override func injectedReload() {
        tableView.render(Box<SectionId, RowId>.empty, animated: false)
        tableView.layoutIfNeeded()
        super.injectedReload()
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
                |---+ renderToggle()

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
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.estimatedSectionFooterHeight = 18
        tableView.estimatedSectionHeaderHeight = 18
        tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        tableView.sectionFooterHeight = UITableViewAutomaticDimension
        tableView.add(to: view).pinEdges(to: view.safeAreaLayoutGuide)
    }

    private func renderFirstSection() -> Section<SectionId, RowId> {
        switch state {
        case .airplaneMode:
            let headerSpec = EmptySpaceComponent.Spec(height: 20, color: .red)
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

    private func renderIconText() -> Node<RowId> {
        switch state {
        case .airplaneMode:
            return RowId.note <> IconTextComponent(image: #imageLiteral(resourceName: "wifi"), title: "WIFI Off")
        case .wifi:
            return RowId.note <> IconTextComponent(image: #imageLiteral(resourceName: "wifi"), title: "WIFI On")
        }
    }
}
