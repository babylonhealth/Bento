import UIKit
import Bento
import BentoKit
import StyleSheets
import ReactiveSwift

class ViewController: UIViewController {
    enum State {
        case airplaneMode
        case wifi
    }

    enum SectionId: Hashable {
        case first
        case second
        case third
        case forth
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
        switch state {
        case .airplaneMode:
            let box = Box<SectionId, RowId>.empty
                |-+ renderFirstSection()
                |---+ renderToggle()
                |---+ renderIconText()

            tableView.render(box)
        case .wifi:
            let box = Box<SectionId, RowId>.empty
                |-+ renderFirstSection()
                |---+ renderIconText()
                |---+ renderToggle()

            tableView.render(box)
        }
    }

    private func setupTableView() {
        tableView.estimatedSectionFooterHeight = 18
        tableView.estimatedSectionHeaderHeight = 18
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.sectionFooterHeight = UITableView.automaticDimension
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

    private func renderThirdSection() -> Section<SectionId, RowId> {
        switch state {
        case .airplaneMode:
            return Section(id: .third,
                           footer: IconTextComponent(image: nil, title: "Airplane"))
        case .wifi:
            return Section(id: .third,
                           header: IconTextComponent(image: nil, title: "WiFi"),
                           footer: EmptySpaceComponent(spec: EmptySpaceComponent.Spec(height: 20, color: .black)))
        }
    }

    private func renderForthSection() -> Section<SectionId, RowId> {
        return Section(id: .forth,
                           footer: LoadingIndicatorComponent(isLoading: true))
    }

    private func renderToggle() -> Node<RowId> {
        let x = #imageLiteral(resourceName: "plane").withRenderingMode(.alwaysOriginal)

        let component = Component.Toggle(
            title: "Airplane mode",
            image: Property(value: .image(x)),
            isOn: self.state == .airplaneMode,
            isEnabled: true,
            styleSheet: Component.Toggle.StyleSheet(
                text: LabelStyleSheet(),
                imageOrLabel: ImageOrLabelView.StyleSheet()
                    .compose(\.tintColor, .red)
                    .compose(\.backgroundColor, .clear)
                )
                .compose(\.imageOrLabel.image.contentMode, .left),
                //.compose(\.imageOrLabel.fixedSize, CGSize(width: 128, height: 128)),
            didChangeValue: { isOn in
                if isOn {
                    self.state = State.airplaneMode
                } else {
                    self.state = State.wifi
                }
            }
        )

        return RowId.toggle <> component
    }

    private func renderIconText() -> Node<RowId> {
        switch state {
        case .airplaneMode:
            return RowId.note <> IconTextComponent(image: #imageLiteral(resourceName: "wifi"), title: "WIFI Off")
                .deletable(deleteActionText: "Delete", didDelete: {
                    print("Delete")
                })
                .on(willDisplayItem: nil, didEndDisplayingItem: nil)
        case .wifi:
            return RowId.note <> IconTextComponent(image: #imageLiteral(resourceName: "wifi"), title: "WIFI On")
                .deletable(deleteActionText: "Delete", didDelete: {
                    print("Delete")
                })
                .on(willDisplayItem: nil, didEndDisplayingItem: nil)
        }
    }
}
