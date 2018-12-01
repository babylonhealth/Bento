import UIKit
import Bento
import BentoKit

final class PinnedSectionsExampleViewController: UIViewController {
    @IBOutlet var collectionView: UICollectionView!
    private lazy var adapter = BoxCollectionViewLayoutProxy<SectionId, RowId>()
    private let layout = StickyFooterCollectionViewLayout<SectionId, RowId>()
    
    private var state: State = .airplaneMode {
        didSet {
            render()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.alwaysBounceVertical = true
        collectionView.render(Box<SectionId, RowId>.empty)
        collectionView.collectionViewLayout = adapter
        render()
    }
    
    @IBAction func refresh() {
        state.toggle()
    }
    
    private func render() {
        switch state {
        case .airplaneMode:
            let box = Box<SectionId, RowId>.empty
                |-+ renderFirstSection()
                |---+ renderToggle()
                |---+ renderIconText()
                |-+ renderSecondSection()
                |---+ renderIconText()
                |---+ renderToggle()
                |-+ renderThirdSection()
                |---+ renderIconText()
                |---+ renderToggle()
            
            adapter.render(box: box, layout: layout)
        case .wifi:
            let box = Box<SectionId, RowId>.empty
                |-+ renderFirstSection()
                |---+ renderIconText()
                |---+ renderToggle()
                |-+ renderSecondSection()
                |---+ renderToggle()
                |---+ renderIconText()
                |---+ renderToggle()
                |---+ renderIconText()
                |---+ renderToggle()
                |---+ renderIconText()
                |---+ renderToggle()
                |---+ renderIconText()
                |---+ renderToggle()
                |---+ renderIconText()
                |---+ renderToggle()
                |---+ renderIconText()
                |---+ renderToggle()
                |---+ renderIconText()
                |---+ renderToggle()
                |---+ renderIconText()
                |---+ renderToggle()
                |---+ renderIconText()
                |-+ renderThirdSection()
                |---+ renderToggle()
                |---+ renderIconText()
            
            adapter.render(box: box, layout: layout)
        }
    }
    
    private func renderFirstSection() -> Section<SectionId, RowId> {
        switch state {
        case .airplaneMode:
            let headerSpec = EmptySpaceComponent.Spec(height: 20, color: .black)
            let footerSpec = EmptySpaceComponent.Spec(height: 20, color: .cyan)
            let headerComponent = EmptySpaceComponent(spec: headerSpec)
            let footerComponent = EmptySpaceComponent(spec: footerSpec)
            
            return Section(id: SectionId.first,
                           header: headerComponent,
                           footer: footerComponent)
        case .wifi:
            let footerSpec = EmptySpaceComponent.Spec(height: 20, color: .green)
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
                           header: EmptySpaceComponent(spec: EmptySpaceComponent.Spec(height: 20, color: .purple)),
                           footer: EmptySpaceComponent(spec: EmptySpaceComponent.Spec(height: 20, color: .red)))
        case .wifi:
            return Section(id: .third,
                           header: EmptySpaceComponent(spec: EmptySpaceComponent.Spec(height: 20, color: .magenta)),
                           footer: EmptySpaceComponent(spec: EmptySpaceComponent.Spec(height: 20, color: .orange)))
        }
    }
    
    private func renderForthSection() -> Section<SectionId, RowId> {
        return Section(id: .forth,
                       footer: LoadingIndicatorComponent(isLoading: true))
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

extension PinnedSectionsExampleViewController {
    enum State {
        case airplaneMode
        case wifi
        
        mutating func toggle() {
            switch self {
            case .airplaneMode:
                self = .wifi
            case .wifi:
                self = .airplaneMode
            }
        }
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
}
