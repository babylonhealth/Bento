import UIKit
import Bento
import StyleSheets

extension Component {
    public final class OptionPicker: AutoRenderable {
        public let configurator: (View) -> Void
        public let styleSheet: StyleSheet

        public init<Option: BentoKit.Option>(
            options: [Option],
            selected: Option?,
            didPickItem: ((Option) -> Void)? = nil,
            styleSheet: StyleSheet = StyleSheet()
        ) {
            self.configurator = { view in
                let adapter = view.picker.getAdapter() as ListPickerAdapter<Option>
                adapter.items = options
                adapter.didPickItem = didPickItem
                view.picker.reloadAllComponents()
                if options.isEmpty == false, let index = selected.flatMap(options.index(of:)) {
                    view.picker.selectRow(index, inComponent: 0, animated: false)
                }
            }
            self.styleSheet = styleSheet
        }
    }
}

extension Component.OptionPicker {
    public  final class View: BaseView {
        fileprivate let picker = UIPickerView()

        public override init(frame: CGRect) {
            super.init(frame: frame)
            setupLayout()
        }

        @available(*, unavailable)
        public required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        private func setupLayout() {
            picker.add(to: self).pinEdges(to: self)
        }
    }
}

extension Component.OptionPicker {
    public final class StyleSheet: BaseViewStyleSheet<View> {}
}

extension Component.OptionPicker: CustomInput {}
