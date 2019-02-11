import Bento
import BentoKit
import UIKit

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

    @IBOutlet var tableView: UITableView!
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0

        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .white
        view.keyboardDismissMode = .interactive
        view.alwaysBounceVertical = true

        return view
    }()

    private var state = State.airplaneMode {
        didSet {
            renderState()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        setupTableView()
        renderState()
    }

    private func setupLayout() {
        let adapter = BentoFlowCollectionViewLayoutAdapter<Int, Int>(with: collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        collectionView.prepareForBoxRendering(with: adapter)
    }

    private func renderState() {
        switch state {
        case .airplaneMode:
            let box = Box<Int, Int>.empty
                |-+ Section(id: 0)
                |---+ renderToggle(id: 0)
                |---+ renderIconText(id: 1)
                |---+ renderIconText(id: 2)
                |---+ renderIconText(id: 3)
                |-+ Section(id: 2)
                |---+ renderToggle(id: 4)
                |---+ renderIconText(id: 5)
                |---+ renderIconText(id: 6)

            collectionView.render(box)
        case .wifi:
            let box = Box<Int, Int>.empty
                |-+ Section(id: 0)
                |---+ renderToggle(id: 0)
                |---+ renderIconText(id: 1)
                |---+ renderIconText(id: 2)
                |---+ renderIconText(id: 3)
                |-+ Section(id: 1)
                |---+ renderIconText(id: 7)
                |-+ Section(id: 2)
                |---+ renderIconText(id: 5)

            collectionView.render(box)
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
        let component = ToggleComponent(isOn: state == .airplaneMode,
                                        title: "Airplane mode",
                                        icon: #imageLiteral(resourceName: "plane")) { isOn in
            if isOn {
                self.state = State.airplaneMode
            } else {
                self.state = State.wifi
            }
        }
        return RowId.toggle <> component
    }

    private func renderToggle(id: Int) -> Node<Int> {
        let component = ToggleComponent(isOn: state == .airplaneMode,
                                        title: "Airplane mode",
                                        icon: #imageLiteral(resourceName: "plane")) { isOn in
            if isOn {
                self.state = State.airplaneMode
            } else {
                self.state = State.wifi
            }
        }
        return id <> component
    }

    private func renderIconText(id: Int) -> Node<Int> {
        switch state {
        case .airplaneMode:
            return id <> IconTextComponent(image: #imageLiteral(resourceName: "wifi"), title: "WIFI Off")
                .deletable(deleteActionText: "Delete", didDelete: {
                    print("Delete")
                })
                .on(willDisplayItem: nil, didEndDisplayingItem: nil)
        case .wifi:
            return id <> IconTextComponent(image: #imageLiteral(resourceName: "wifi"), title: "WIFI On")
                .deletable(deleteActionText: "Delete", didDelete: {
                    print("Delete")
                })
                .on(willDisplayItem: nil, didEndDisplayingItem: nil)
        }
    }
}

public final class BentoFlowCollectionViewLayoutAdapter<SectionID: Hashable, ItemID: Hashable>
    : CollectionViewAdapterBase<SectionID, ItemID>,
    UICollectionViewDataSource,
    UICollectionViewDelegate,
    UICollectionViewDelegateFlowLayout {
    private let itemsSizeCache = SizeCache<ItemID>()
    private let headerSizeCache = SizeCache<SectionID>()
    private let footerSizeCache = SizeCache<SectionID>()

    public override init(with collectionView: UICollectionView) {
        super.init(with: collectionView)
    }

    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAt indexPath: IndexPath) -> CGSize {
        print("🔥🔥🔥sizeForItemAt", indexPath.section, indexPath.row)
        let node = sections[indexPath.section].items[indexPath.row]
        guard let size = itemsSizeCache.size(for: node.id, width: collectionView.bounds.width) else {
            let size: CGSize
            if let heightCustomizing = node.component(as: HeightCustomizing.self) {
                size = CGSize(width: collectionView.bounds.width,
                              height: heightCustomizing.height(forWidth: collectionView.bounds.width,
                                                               inheritedMargins: collectionView.layoutMargins.horizontal))
            } else {
                size = node.sizeBoundTo(width: collectionView.bounds.width)
            }
            itemsSizeCache.set(size: CGSize(width: ceil(size.width), height: ceil(size.height)),
                               for: node.id,
                               width: collectionView.bounds.width)

            return self.collectionView(collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath)
        }

        return size
    }

    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               referenceSizeForHeaderInSection section: Int) -> CGSize {
        print("🔥🔥🔥referenceSizeForHeaderInSection", section)
        let _section = sections[section]
        guard let size = headerSizeCache.size(for: _section.id, width: collectionView.bounds.width) else {
            let size: CGSize
            if let heightCustomizing = _section.component(of: .header, as: HeightCustomizing.self) {
                size = CGSize(width: collectionView.bounds.width,
                              height: heightCustomizing.height(forWidth: collectionView.bounds.width,
                                                               inheritedMargins: collectionView.layoutMargins.horizontal))
            } else {
                size = _section.componentSize(of: .header,
                                              fittingWidth: collectionView.bounds.width,
                                              inheritedMargins: .zero) ?? .zero
            }
            headerSizeCache.set(size: CGSize(width: ceil(size.width), height: ceil(size.height)),
                                for: _section.id,
                                width: collectionView.bounds.width)

            return self.collectionView(collectionView,
                                       layout: collectionViewLayout,
                                       referenceSizeForHeaderInSection: section)
        }

        return size
    }

    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               referenceSizeForFooterInSection section: Int) -> CGSize {
        print("🔥🔥🔥referenceSizeForFooterInSection", section)
        let _section = sections[section]
        guard let size = footerSizeCache.size(for: _section.id, width: collectionView.bounds.width) else {
            let size: CGSize
            if let heightCustomizing = _section.component(of: .footer, as: HeightCustomizing.self) {
                size = CGSize(width: collectionView.bounds.width,
                              height: heightCustomizing.height(forWidth: collectionView.bounds.width,
                                                               inheritedMargins: collectionView.layoutMargins.horizontal))
            } else {
                size = _section.componentSize(of: .footer,
                                              fittingWidth: collectionView.bounds.width,
                                              inheritedMargins: .zero) ?? .zero
            }
            footerSizeCache.set(size: CGSize(width: ceil(size.width), height: ceil(size.height)),
                                for: _section.id,
                                width: collectionView.bounds.width)

            return self.collectionView(collectionView,
                                       layout: collectionViewLayout,
                                       referenceSizeForFooterInSection: section)
        }

        return size
    }

    private class SizeCache<ID: Hashable> {
        private struct Key: Hashable {
            let id: ID
            let width: CGFloat
        }

        private var cache: [Key: CGSize] = [:]

        func size(for id: ID, width: CGFloat) -> CGSize? {
            return cache[Key(id: id, width: width)]
        }

        func set(size: CGSize, for id: ID, width: CGFloat) {
            cache[Key(id: id, width: width)] = size
        }

        func clean() {
            cache = [:]
        }
    }
}
