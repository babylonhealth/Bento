import Bento
import UIKit

extension Component {
    public final class DatePicker: AutoRenderable {
        public let configurator: (View) -> Void
        public let styleSheet: StyleSheet

        public init(
            date: Date? = nil,
            minDate: Date? = nil,
            maxDate: Date? = nil,
            calendar: Calendar? = nil,
            datePickerMode: UIDatePicker.Mode = .date,
            styleSheet: StyleSheet = StyleSheet(),
            didPickDate: ((Date) -> Void)? = nil
        ) {
            self.configurator = { view in
                view.datePicker.date = date ?? Date()
                view.datePicker.minimumDate = minDate
                view.datePicker.maximumDate = maxDate
                view.datePicker.calendar = calendar
                view.datePicker.datePickerMode = datePickerMode
                view.didPickDate = didPickDate
            }
            self.styleSheet = styleSheet
        }
    }
}

extension Component.DatePicker {
    public final class View: BaseView {
        fileprivate let datePicker = UIDatePicker()
        fileprivate var didPickDate: ((Date) -> Void)?

        override init(frame: CGRect) {
            super.init(frame: frame)
            datePicker.addTarget(self, action: #selector(View.pickerDidChange), for: .valueChanged)
            setupLayout()
        }

        @available(*, unavailable)
        public required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        private func setupLayout() {
            stack(.vertical)(
                datePicker
            )
            .add(to: self)
            .pinEdges(to: self)
        }

        @objc
        private func pickerDidChange() {
            didPickDate?(datePicker.date)
        }
    }
}

extension Component.DatePicker {
    public final class StyleSheet: BaseViewStyleSheet<View> {}
}

extension Component.DatePicker: CustomInput {}
