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
        return components.map { $0.builder(visualDependencies) }
    }

    public static func |-+(builder: FormBuilder, component: Component) -> FormBuilder {
        return FormBuilder(components: builder.components + [component])
    }

    public static func |-* (builder: FormBuilder, components: [FormBuilder.Component]) -> FormBuilder {
        var sum = builder.components
        sum.append(contentsOf: components)
        return FormBuilder(components: sum)
    }

    public static func |-* (builder: FormBuilder, other: FormBuilder) -> FormBuilder {
        return FormBuilder(components: builder.components + other.components)
    }

    public static func |-* (builder: FormBuilder, generator: () -> FormBuilder) -> FormBuilder {
        return builder |-* generator()
    }

    public static func |-? (builder: FormBuilder, validator: Validator<FormBuilder>) -> FormBuilder {
        return validator.generate(with: builder) ?? builder
    }

    public static func |-| (builder: FormBuilder, height: Float) -> FormBuilder {
        return builder |-+ .space(height: height)
    }
}

extension FormBuilder {

    public struct Component {
        fileprivate let builder: (VisualDependenciesProtocol) -> FormComponent

        public init(_ builder: @escaping (VisualDependenciesProtocol) -> FormComponent) {
            self.builder = builder
        }

        public static func space(height: Float) -> Component {
            return Component { visualDependencies in
                return .space(.init(height: height, visualDependencies: visualDependencies))
            }
        }

        public static func header(text: String) -> Component {
            return Component { visualDependencies in
                return .description(.init(text: text, type: .header, visualDependencies: visualDependencies))
            }
        }

        public static func headline(text: String) -> Component {
            return Component { visualDependencies in
                return .description(.init(text: text, type: .headline, visualDependencies: visualDependencies))
            }
        }

        public static func primaryButton(text: String, action: Action<Void, Void, NoError>) -> Component {
            return Component { visualDependencies in
                let style = visualDependencies.styles.buttonBackgroundBrandColor
                    .composing(with: visualDependencies.styles.buttonRoundCorners)
                    .composing(with: visualDependencies.styles.buttonTextBody)

                let disabledStyle = visualDependencies.styles.buttonTitleDisabledColor
                    .composing(with: visualDependencies.styles.buttonRoundCorners)
                    .composing(with: visualDependencies.styles.buttonTextBody)

                let spec = ActionCellViewSpec(title: text, buttonStyle: style, disabledButtonStyle: disabledStyle, hasDynamicHeight: false)
                let viewModel = ActionCellViewModel(action: action, isLoading: action.isExecuting)

                return .actionButton(viewModel, spec)
            }
        }

        public static func secondaryButton(text: String, hasDynamicHeight: Bool = false, action: Action<Void, Void, NoError>) -> Component {
            return Component { visualDependencies in
                let style = visualDependencies.styles.buttonTitleBrandColor
                    .composing(with: visualDependencies.styles.buttonTextBody)
                let spec = ActionCellViewSpec(title: text, buttonStyle: style, hasDynamicHeight: hasDynamicHeight)
                let viewModel = ActionCellViewModel(action: action, isLoading: action.isExecuting)

                return .actionButton(viewModel, spec)
            }
        }

        public static func textField(placeholder: String, text: ValidatingProperty<String, InvalidInput>) -> Component {
            return Component { visualDependencies in
                return .textInput(
                    TextInputCellViewModel(placeholder: placeholder,
                                           text: text,
                                           isSecure: false,
                                           visualDependencies: visualDependencies))
            }
        }

        public static func passwordField(placeholder: String, text: ValidatingProperty<String, InvalidInput>) -> Component {
            return Component { visualDependencies in
                return .textInput(
                    TextInputCellViewModel(placeholder: placeholder,
                                           text: text,
                                           isSecure: true,
                                           visualDependencies: visualDependencies))
            }
        }

        public static func titledTextField(title: String, placeholder: String, text: ValidatingProperty<String, InvalidInput>) -> Component {
            return Component { visualDependencies in
                return .titledTextInput(
                    TitledTextInputCellViewModel(title: title,
                                                 placeholder: placeholder,
                                                 text: text,
                                                 visualDependencies: visualDependencies))
            }
        }

        public static func phoneTextField(title: String, placeholder: String, countryCode: MutableProperty<String>, phoneNumber: MutableProperty<String>) -> Component {
            return Component { visualDependencies in
                return .phoneTextInput(
                    PhoneInputCellViewModel(title: title,
                                            placeholder: placeholder,
                                            countryCode: countryCode,
                                            phoneNumber: phoneNumber,
                                            visualDependencies: visualDependencies))
            }
        }

        public static func selectionField(title: String, value: Property<String>, action: Action<Void, Void, NoError>) -> Component {
            return Component { visualDependencies in
                return .actionInput(
                    ActionInputCellViewModel(visualDependencies: visualDependencies,
                                             title: title,
                                             input: value,
                                             inputTextAlignment: .left,
                                             selected: action))
            }
        }

        public static func buttonField(title: String, action: Action<Void, Void, NoError>) -> Component {
            return Component { visualDependencies in
                let style = visualDependencies.styles.labelTextBrandColor
                    .composing(with: visualDependencies.styles.labelTextBody)

                return .actionInput(
                    ActionInputCellViewModel(visualDependencies: visualDependencies,
                                             title: title,
                                             input: nil,
                                             inputTextAlignment: .left,
                                             selected: action,
                                             accessory: .none,
                                             titleStyle: style))
            }
        }

        public static func iconSelectionField(icon: SignalProducer<UIImage, NoError>, title: String, value: Property<String>, action: Action<Void, Void, NoError>) -> Component {
            return Component { visualDependencies in
                return .actionInput(
                    ActionInputCellViewModel(visualDependencies: visualDependencies,
                                             icon: icon,
                                             title: title,
                                             input: value,
                                             inputTextAlignment: .right,
                                             selected: action))
            }
        }

        public static func avatarSelectionField(icon: SignalProducer<UIImage, NoError>, subIcon: UIImage?, title: Property<String>, input: Property<String>? = nil, isVertical: Bool = false, action: Action<Void, Void, NoError>, subtitleStyle: UIViewStyle<UILabel>? = nil) -> Component {
            return Component { visualDependencies in
                return .actionInput(
                    ActionInputCellViewModel(visualDependencies: visualDependencies,
                                             icon: icon,
                                             subIcon: subIcon,
                                             iconStyle: .largeRoundAvatar,
                                             title: title,
                                             input: input,
                                             inputTextAlignment: .left,
                                             selected: action,
                                             subtitleStyle: subtitleStyle,
                                             isVertical: isVertical))
            }
        }

        public static func segmentedField(options: [SegmentedCellViewModel.Option], selection: MutableProperty<Int>) -> Component {
            return Component { visualDependencies in
                return .segmentedInput(
                    SegmentedCellViewModel(options: options,
                                           selection: selection,
                                           visualDependencies: visualDependencies))
            }
        }

        public static func noteField(placeholder: String, text: ValidatingProperty<String, InvalidInput>, addPhotosAction: Action<Void, Void, NoError>) -> Component {
            return Component { visualDependencies in
                return .noteInput(
                    NoteInputCellViewModel(placeholder: placeholder,
                                           text: text,
                                           addPhotosAction: addPhotosAction,
                                           visualDependencies: visualDependencies))
            }
        }

        public static func note(_ text: Property<String>) -> Component {
            return Component { visualDependencies in
                return .note(NoteCellViewModel(text: text,
                                               visualDependencies: visualDependencies))
            }
        }

        public static func textOptionsField(items: Property<[String]>, selectionAction: Action<Int, Void, NoError>, spec: TextOptionsCellViewSpec, headline: String? = nil) -> Component {
            return Component { visualDependencies in
                return .textOptionsInput(TextOptionsCellViewModel(items: items, selectionAction: selectionAction, headline: headline), spec)
            }
        }

        public static func imageOptionsField(items: [UIImage], selectionAction: Action<Int, Void, NoError>, destructiveAction: Action<Int, Void, NoError>, spec: ImageOptionsCellViewSpec) -> Component {
            return Component { visualDependencies in
                return .imageOptionsInput(ImageOptionsCellViewModel(items: items, selectionAction: selectionAction, destructiveAction: destructiveAction), spec)
            }
        }

        public static func toggle(title: String, isOn: MutableProperty<Bool>) -> Component {
            return Component { visualDependencies in
                return .toggle(
                    ToggleCellViewModel(title: title,
                                        isOn: isOn,
                                        visualDependencies: visualDependencies))
            }
        }

        public static func imageField(image: SignalProducer<UIImage, NoError>, imageSize: CGSize, imageAlignment: ImageCellAlignment = .centered, isRounded: Bool = false) -> Component {
            return Component { visualDependencies in
                return .image(ImageCellViewModel(image: image,
                                                 imageSize: imageSize,
                                                 visualDependencies: visualDependencies,
                                                 imageAlignment: imageAlignment,
                                                 isRounded: isRounded))
            }
        }

        public static func activityIndicator(isRefreshing: Property<Bool>) -> Component {
            return Component { visualDependencies in
                return .activityIndicator(ActivityIndicatorCellViewModel(isRefreshing: isRefreshing),
                                          ActivityIndicatorCellViewSpec(cellStyle: visualDependencies.styles.backgroundTransparentColor))
            }
        }

        public static func titledList(title: String, items: [TitledListItem]) -> Component {
            return Component { visualDependencies in
                let listItemViewSpec = TitledListItemViewSpec(titleColor: .black,
                                                          titleStyle: visualDependencies.styles.labelTextFootnote,
                                                          descriptionColor: Colors.silverGrey,
                                                          descriptionStyle: visualDependencies.styles.labelTextFootnote)
                return .titledList(TitledListCellViewModel(title: title,
                                                           items: items),
                                   TitledListCellViewSpec(titleColor: .black,
                                                          titleStyle: visualDependencies.styles.labelTextTitle3.composing(with: visualDependencies.styles.labelTextStyleWithMediumWeight),
                                                          itemViewSpec: listItemViewSpec))
            }
        }

        public static func multiselectionItem(
            title: String,
            icon: SignalProducer<UIImage, NoError>,
            identifier: Int,
            in group: SelectionCellGroupViewModel,
            spec: SelectionCellViewSpec
        ) -> Component {
            return Component { visualDependencies in
                let viewModel = SelectionCellViewModel(title: title,
                                                       icon: icon,
                                                       identifier: identifier)
                return .selection(viewModel, group: group, spec: spec)
            }
        }

        public static func custom(_ component: FormComponent) -> Component {
            return Component { _ in component }
        }
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
