
public enum AccessoryType {
    case disclosureIndicator
    case detailDisclosureButton
    case checkmark
    case detailButton
    
    var cellType: UITableViewCell.AccessoryType {
        switch self {
        case .disclosureIndicator:
            return .disclosureIndicator
        case .detailDisclosureButton:
            return .detailDisclosureButton
        case .checkmark:
            return .checkmark
        case .detailButton:
            return .detailButton
        }
    }
}

protocol AccessoryProviding {
    var accessory: AccessoryType { get }
    func selectAccessory()
}

final class AccessoryProvidingComponent<Base: Renderable>: AnyRenderableBox<Base>, AccessoryProviding where Base.View: UIView {
    private let source: AnyRenderableBox<Base>
    private let didSelectAccessory: (() -> Void)?
    let accessory: AccessoryType
    
    init(source: Base, accessory: AccessoryType, didSelectAccessory: (() -> Void)?) {
        self.source = AnyRenderableBox(source)
        self.accessory = accessory
        self.didSelectAccessory = didSelectAccessory
        super.init(source)
    }
    
    func selectAccessory() {
        didSelectAccessory?()
    }
    
    override func cast<T>(to type: T.Type) -> T? {
        if type == AccessoryProviding.self {
            return self as? T
        }
        return source.cast(to: type)
    }
}
