import UIKit

public protocol Option: Equatable {
    var displayName: String { get }
}

public final class ListPickerAdapter<Option: BentoKit.Option>: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
    public var items: [Option] = []

    public var didPickItem: ((Option) -> Void)?

    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return items.count
    }

    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return items[row].displayName
    }

    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        didPickItem?(items[row])
    }
}

extension UIPickerView {
    private struct AssociatedKey {
        static let key = UnsafeMutablePointer<CChar>.allocate(capacity: 1)
    }

    public func getAdapter<Option>() -> ListPickerAdapter<Option> {
        guard let adapter = objc_getAssociatedObject(self, AssociatedKey.key) as? ListPickerAdapter<Option> else {
            let adapter = ListPickerAdapter<Option>()
            self.dataSource = adapter
            self.delegate = adapter
            objc_setAssociatedObject(self, AssociatedKey.key, adapter, .OBJC_ASSOCIATION_RETAIN)
            return adapter
        }
        return adapter
    }
}
