import Bento

final class CustomInputSnapshotTests: SnapshotTestCase {
    override func setUp() {
        super.setUp()
        self.recordMode = false
    }

    func test_component_with_customInput_visible() {
        let component = Component.TextInput(
            title: "Title",
            placeholder: "Placeholder",
            text: nil,
            styleSheet: Component.TextInput.StyleSheet()
        ).customInput(Component.DatePicker(
                date: Date(),
                minDate: Date(),
                calendar: Calendar.current,
                datePickerMode: .date,
                styleSheet: Component.DatePicker.StyleSheet()
            )
        )

        verifyComponentForAllSizes(component: component)
    }
}
