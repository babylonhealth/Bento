import ReactiveSwift
import enum Result.NoError

precedencegroup ChainingPrecedence {
    associativity: left
    higherThan: TernaryPrecedence
}

infix operator |-+ : ChainingPrecedence // Compose with a new component
infix operator |-* : ChainingPrecedence // Compose with another builder
infix operator |-? : ChainingPrecedence // Compose components pending on a boolean condition
infix operator |-| : ChainingPrecedence // Compose with an empty space using a specific height

public struct FormBuilder {

    let components: [Component]

    public static var empty: FormBuilder {
        return FormBuilder()
    }

    private init(components: [Component] = []) {
        self.components = components
    }

    public func build(with visualDependencies: VisualDependenciesProtocol) -> [FormComponent] {
        return components
            .map { $0.formComponent(with: visualDependencies) }
            .flatMap { $0 }
    }

    public static func |-+(builder: FormBuilder, component: Component) -> FormBuilder {
        var components = builder.components
        components.append(component)
        return FormBuilder(components: components)
    }

    public static func |-* (builder: FormBuilder, other: FormBuilder) -> FormBuilder {
        var components = builder.components
        components.append(contentsOf: other.components)
        return FormBuilder(components: components)
    }

    public static func |-* (builder: FormBuilder, generator: () -> FormBuilder) -> FormBuilder {
        return builder |-* generator()
    }

    public static func |-+ (builder: FormBuilder, sectioner: Sectioner) -> FormBuilder {
        return builder |-+ .section(sectioner.generator(.empty))
    }

    public static func |-? (builder: FormBuilder, validator: Validator<FormBuilder>) -> FormBuilder {
        return validator.generate(with: builder) ?? builder
    }

    public static func |-| (builder: FormBuilder, height: Float) -> FormBuilder {
        return builder |-+ .space(height: height)
    }

    public struct Sectioner {

        let generator: (FormSectionBuilder) -> FormSectionBuilder

        public static func section(_ generator: @escaping (FormSectionBuilder) -> FormSectionBuilder) -> Sectioner {
            return Sectioner(generator: generator)
        }
    }
}

extension FormBuilder {

    public enum Component {
        case space(height: Float)
        case header(text: String)
        case headline(text: String)
        case section(FormSectionBuilder)
        case primaryButton(text: String, action: Action<Void, Void, NoError>)
        case secondaryButton(text: String, hasDynamicHeight: Bool, action: Action<Void, Void, NoError>)
        case custom(FormComponent)

        public func formComponent(with visualDependencies: VisualDependenciesProtocol) -> [FormComponent] {
            switch self {
            case let .space(height):
                return [
                    .space(.init(height: height, visualDependencies: visualDependencies))
                ]
            case let .header(text):
                return [
                    .description(.init(text: text, type: .header, visualDependencies: visualDependencies))
                ]
            case let .headline(text):
                return [
                    .description(.init(text: text, type: .headline, visualDependencies: visualDependencies))
                ]
            case let .primaryButton(text, action):
                let style = visualDependencies.styles.buttonBackgroundBrandColor
                    .composing(with: visualDependencies.styles.buttonRoundCorners)
                    .composing(with: visualDependencies.styles.buttonTextBody)
                let spec = ActionCellViewSpec(title: text, buttonStyle: style, hasDynamicHeight: false)
                let viewModel = ActionCellViewModel(action: action, isLoading: action.isExecuting)
                return [.actionButton(viewModel, spec)]
            case let .secondaryButton(text, hasDynamicHeight, action):
                let style = visualDependencies.styles.buttonTitleBrandColor
                    .composing(with: visualDependencies.styles.buttonTextBody)
                let spec = ActionCellViewSpec(title: text, buttonStyle: style, hasDynamicHeight: hasDynamicHeight)
                let viewModel = ActionCellViewModel(action: action, isLoading: action.isExecuting)
                return [.actionButton(viewModel, spec)]
            case let .section(builder):
                return builder.build(with: visualDependencies)
            case let .custom(formComponent):
                return [formComponent]
            }
        }
    }
}

// MARK: -

public struct FormSectionBuilder {

    public enum Component {
        case textField(placeholder: String, text: ValidatingProperty<String, InvalidInput>)
        case passwordField(placeholder: String, text: ValidatingProperty<String, InvalidInput>)
        case titledTextField(title: String, placeholder: String, text: ValidatingProperty<String, InvalidInput>)
        case phoneTextField(title: String, placeholder: String, countryCode: MutableProperty<String>, phoneNumber: MutableProperty<String>)
        case selectionField(title: String, value: Property<String>, action: Action<Void, Void, NoError>)
        case iconSelectionField(icon: UIImage, title: String, value: Property<String>, action: Action<Void, Void, NoError>)
        case segmentedField(options: [SegmentedCellViewModel.Option], initial: Int)
        case toggle(title: String, isOn: MutableProperty<Bool>)
        case custom(FormComponent)

        public func formComponent(with visualDependencies: VisualDependenciesProtocol) -> FormComponent {
            switch self {
            case let .textField(placeholder, text):
                return .textInput(
                    TextInputCellViewModel(placeholder: placeholder,
                                           text: text,
                                           isSecure: false,
                                           visualDependencies: visualDependencies))
            case let .passwordField(placeholder, text):
                return .textInput(
                    TextInputCellViewModel(placeholder: placeholder,
                                           text: text,
                                           isSecure: true,
                                           visualDependencies: visualDependencies))
            case let .titledTextField(title, placeholder, text):
                return .titledTextInput(
                    TitledTextInputCellViewModel(title: title,
                                                 placeholder: placeholder,
                                                 text: text,
                                                 visualDependencies: visualDependencies))
            case let .phoneTextField(title, placeholder, countryCode, phoneNumber):
                return .phoneTextInput(
                    PhoneInputCellViewModel(title: title,
                                            placeholder: placeholder,
                                            countryCode: countryCode,
                                            phoneNumber: phoneNumber,
                                            visualDependencies: visualDependencies))
            case let .selectionField(title, value, action):
                return .actionInput(
                    ActionInputCellViewModel(visualDependencies: visualDependencies,
                                             title: title,
                                             input: value,
                                             selected: action))
            case let .iconSelectionField(icon, title, value, action):
                return .actionIconInput(
                    ActionIconInputCellViewModel(visualDependencies: visualDependencies,
                                                 icon: icon,
                                                 title: title,
                                                 input: value,
                                                 selected: action))
            case let .segmentedField(options, initial):
                return .segmentedInput(
                    SegmentedCellViewModel(options: options,
                                           selectedIndex: initial,
                                           visualDependencies: visualDependencies))
            case let .toggle(title, isOn):
                return .toggle(
                    ToggleCellViewModel(title: title,
                                        isOn: isOn,
                                        visualDependencies: visualDependencies)
                )
            case let .custom(formComponent):
                return formComponent
            }
        }
    }

    public static var empty: FormSectionBuilder {
        return FormSectionBuilder()
    }

    fileprivate let components: [FormSectionBuilder.Component]

    public init(generator: (FormSectionBuilder) -> FormSectionBuilder) {
        self.init()
        self = generator(self)
    }

    private init(components: [FormSectionBuilder.Component] = []) {
        self.components = components
    }

    private func completeSeparator(with visualDependencies: VisualDependenciesProtocol) -> FormComponent {
        return .separator(SeparatorCellViewModel(isFullCell: true, visualDependencies: visualDependencies))
    }

    private func partialSeparator(with visualDependencies: VisualDependenciesProtocol) -> FormComponent {
        return .separator(SeparatorCellViewModel(isFullCell: false, visualDependencies: visualDependencies))
    }

    public static func |-+(builder: FormSectionBuilder, component: FormSectionBuilder.Component) -> FormSectionBuilder {
        var components = builder.components
        components.append(component)
        return FormSectionBuilder(components: components)
    }

    public static func |-+(builder: FormSectionBuilder, component: [FormSectionBuilder.Component]) -> FormSectionBuilder {
        var components = builder.components
        components.append(contentsOf: component)
        return FormSectionBuilder(components: components)
    }

    public static func |-* (builder: FormSectionBuilder, other: FormSectionBuilder) -> FormSectionBuilder {
        var components = builder.components
        components.append(contentsOf: other.components)
        return FormSectionBuilder(components: components)
    }

    public static func |-* (builder: FormSectionBuilder, generator: () -> FormSectionBuilder) -> FormSectionBuilder {
        return builder |-* generator()
    }

    public static func |-? (builder: FormSectionBuilder, validator: Validator<FormSectionBuilder>) -> FormSectionBuilder {
        return validator.generate(with: builder) ?? builder
    }

    fileprivate func build(with visualDependencies: VisualDependenciesProtocol) -> [FormComponent] {
        precondition(components.count > 0)

        let delimiterSeparator = [completeSeparator(with: visualDependencies)]
        let interleavingSeparator = [partialSeparator(with: visualDependencies)]

        let interleavedFormComponents = components
            .map { [$0.formComponent(with: visualDependencies)] }
            .joined(separator: interleavingSeparator)
            .flatMap { $0 }

        return [delimiterSeparator, interleavedFormComponents, delimiterSeparator].flatMap { $0 }
    }
}


// MARK: - 

public struct Validator<T> {

    public let condition: () -> Bool
    public let generator: (T) -> T

    public func generate(with formBuilder: T) -> T? {
        return condition() ? generator(formBuilder) : nil
    }

    public static func iff(_ condition: @autoclosure @escaping () -> Bool, generator: @escaping (T) -> T) -> Validator<T> {
        return Validator(condition: condition, generator: generator)
    }
}
