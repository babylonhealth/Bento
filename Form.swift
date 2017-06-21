import ReactiveSwift

protocol Form {
	var components: Property<[FormComponent]> { get }
	var submiting: Property<Bool> { get }

	func setup()
}

extension Form {
	func setup() {
        components.producer.startWithValues { [submiting] components in
            components
                .flatMap { cell in cell.interactable }
                .forEach { interactable in interactable.isInteractable <~ submiting.map(!) }
        }
	}
}

protocol FocusableForm: Form {
	var focusableController: FocusableController { get }

	func enableAutoFocus(atIndex index: Int)
}

extension FocusableForm {
	func enableAutoFocus(atIndex index: Int = 0) {
		focusableController.focus(elementAt: index)
	}
}
