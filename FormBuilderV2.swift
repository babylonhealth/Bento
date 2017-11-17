import ReactiveSwift
import enum Result.NoError

public struct FormBuilderV2<Identifier: Hashable> {

    let components: [Component]

    public static var empty: FormBuilderV2<Identifier> {
        return FormBuilderV2()
    }

    internal init(components: [Component] = []) {
        self.components = components
    }

    public func build(style: FormStyle = .topYAligned, with visualDependencies: VisualDependenciesProtocol) -> FormTree<Identifier> {
        return FormTree(items: components.map { FormItem(id: $0.id, component: $0.builder(visualDependencies)) },
                        style: style)
    }

    public static func |-+(builder: FormBuilderV2<Identifier>, component: Component) -> FormBuilderV2<Identifier> {
        return FormBuilderV2(components: builder.components + [component])
    }

    public static func |-* (builder: FormBuilderV2<Identifier>, components: [FormBuilderV2.Component]) -> FormBuilderV2<Identifier> {
        var sum = builder.components
        sum.append(contentsOf: components)
        return FormBuilderV2(components: sum)
    }

    public static func |-* (builder: FormBuilderV2<Identifier>, other: FormBuilderV2<Identifier>) -> FormBuilderV2<Identifier> {
        return FormBuilderV2(components: builder.components + other.components)
    }

    public static func |-* (builder: FormBuilderV2<Identifier>, generator: () -> FormBuilderV2<Identifier>) -> FormBuilderV2<Identifier> {
        return builder |-* generator()
    }

    public static func |-? (builder: FormBuilderV2<Identifier>, validator: Validator<FormBuilderV2<Identifier>>) -> FormBuilderV2<Identifier> {
        return validator.generate(with: builder) ?? builder
    }

    public static func |-| (builder: FormBuilderV2<Identifier>, height: Float) -> FormBuilderV2<Identifier> {
        return builder |-+ .space(height: height)
    }
}

extension FormBuilderV2 {

    public struct Component {
        fileprivate let id: Identifier?
        fileprivate let builder: (VisualDependenciesProtocol) -> FormComponent

        public init(with id: Identifier?, _ builder: @escaping (VisualDependenciesProtocol) -> FormComponent) {
            self.id = id
            self.builder = builder
        }

        public static func space(height: Float) -> Component {
            return Component(with: nil) { visualDependencies in
                return .space(.init(height: height, visualDependencies: visualDependencies))
            }
        }

        public static func header(_ id: Identifier, text: String) -> Component {
            return description(id, .header, text: text)
        }

        public static func headline(_ id: Identifier, text: String) -> Component {
            return description(id, .headline, text: text)
        }

        public static func description(_ id: Identifier, _ type: DescriptionCellType, horizontalLayout: DescriptionHorizontalLayout = .fill, text: String, selected: Action<Void, Void, NoError>? = nil) -> Component {
            return Component(with: id) { visualDependencies in
                return .description(.init(text: text, type: type, horizontalLayout: horizontalLayout, visualDependencies: visualDependencies, selected: selected))
            }
        }

        public static func actionDescription(_ id: Identifier, _ description: NSAttributedString, action: Action<Void, Void, NoError>) -> Component {
            return Component(with: id) { visualDependencies in
                return .actionDescription(ActionDescriptionCellViewModel(visualDependencies: visualDependencies,
                                                                         title: description,
                                                                         action: action))
            }
        }

        public static func facebookButton(_ id: Identifier, title: String, action: Action<Void, Void, NoError>) -> Component {
            return Component(with: id) { visualDependencies in
                let style = visualDependencies.styles.buttonFacebook
                    .composing(with: visualDependencies.styles.buttonRoundCorners)
                    .composing(with: visualDependencies.styles.buttonTextBody)

                let spec = ActionCellViewSpec(title: title, buttonStyle: style, hasDynamicHeight: false)
                let viewModel = ActionCellViewModel(action: action, isLoading: action.isExecuting)

                return .actionButton(viewModel, spec)
            }
        }

        public static func primaryButton(_ id: Identifier, text: String, action: Action<Void, Void, NoError>) -> Component {
            return Component(with: id) { visualDependencies in
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

        public static func secondaryButton(_ id: Identifier, text: String, hasDynamicHeight: Bool = false, isDestructive: Bool = false, action: Action<Void, Void, NoError>) -> Component {
            return Component(with: id) { visualDependencies in
                let styles = visualDependencies.styles
                let style = (isDestructive ? styles.buttonTitleDestructiveColor : styles.buttonTitleBrandColor)
                    .composing(with: visualDependencies.styles.buttonTextBody)
                let spec = ActionCellViewSpec(title: text, buttonStyle: style, hasDynamicHeight: hasDynamicHeight)
                let viewModel = ActionCellViewModel(action: action, isLoading: action.isExecuting)

                return .actionButton(viewModel, spec)
            }
        }

        public static func cellButton(_ id: Identifier,
                                      text: String,
                                      hasDynamicHeight: Bool = false,
                                      action: Action<Void, Void, NoError>,
                                      buttonMargins: CGFloat) -> Component {
            return Component(with: id) { visualDependencies in
                let style = visualDependencies.styles.buttonTitleBrandColor
                    .composing(with: visualDependencies.styles.buttonTextBody)
                    .composing(with: visualDependencies.styles.buttonBackgroundWhiteColor)
                let spec = ActionCellViewSpec(title: text, buttonStyle: style, hasDynamicHeight: hasDynamicHeight)
                let viewModel = ActionCellViewModel(action: action, isLoading: action.isExecuting, margins: buttonMargins)

                return .actionButton(viewModel, spec)
            }
        }

        public static func textField(
            _ id: Identifier,
            icon: SignalProducer<UIImage, NoError>? = nil,
            placeholder: String,
            text: ValidatingProperty<String, InvalidInput>,
            clearsOnBeginEditing: Bool = false,
            autocapitalizationType: UITextAutocapitalizationType = .sentences,
            autocorrectionType: UITextAutocorrectionType = .default,
            keyboardType: UIKeyboardType = .default,
            editingDidEndAction: Action<String?, Void, NoError> = Action { _ in return .empty }
        ) -> Component {
            return Component(with: id) { visualDependencies in
                return .textInput(
                    TextInputCellViewModel(icon: icon,
                                           placeholder: placeholder,
                                           text: text,
                                           isSecure: false,
                                           clearsOnBeginEditing: clearsOnBeginEditing,
                                           autocapitalizationType: autocapitalizationType,
                                           autocorrectionType: autocorrectionType,
                                           editingDidEndAction: editingDidEndAction,
                                           visualDependencies: visualDependencies))
            }
        }

        public static func passwordField(_ id: Identifier, placeholder: String, text: ValidatingProperty<String, InvalidInput>) -> Component {
            return Component(with: id) { visualDependencies in
                return .textInput(
                    TextInputCellViewModel(placeholder: placeholder,
                                           text: text,
                                           isSecure: true,
                                           visualDependencies: visualDependencies))
            }
        }

        public static func titledPasswordField(_ id: Identifier, title: String, placeholder: String, text: ValidatingProperty<String, InvalidInput>) -> Component {
            return Component(with: id) { visualDependencies in
                return .titledTextInput(
                    TitledTextInputCellViewModel(title: title,
                                                 placeholder: placeholder,
                                                 text: text,
                                                 isSecure: true,
                                                 visualDependencies: visualDependencies))
            }
        }

        public static func titledTextField(_ id: Identifier,
                                           title: String,
                                           placeholder: String,
                                           text: ValidatingProperty<String, InvalidInput>,
                                           isEnabled: Property<Bool> = Property(value: true),
                                           autocapitalizationType: UITextAutocapitalizationType = .sentences,
                                           autocorrectionType: UITextAutocorrectionType = .default,
                                           keyboardType: UIKeyboardType = .default ) -> Component {

            return Component(with: id) { visualDependencies in
                return .titledTextInput(
                    TitledTextInputCellViewModel(title: title,
                                                 placeholder: placeholder,
                                                 text: text,
                                                 isEnabled: isEnabled,
                                                 autocapitalizationType: autocapitalizationType,
                                                 autocorrectionType: autocorrectionType,
                                                 keyboardType: keyboardType,
                                                 visualDependencies: visualDependencies))
            }
        }

        public static func phoneTextField(_ id: Identifier, title: String, placeholder: String, countryCode: MutableProperty<String>, phoneNumber: MutableProperty<String>) -> Component {
            return Component(with: id) { visualDependencies in
                return .phoneTextInput(
                    PhoneInputCellViewModel(title: title,
                                            placeholder: placeholder,
                                            countryCode: countryCode,
                                            phoneNumber: phoneNumber,
                                            visualDependencies: visualDependencies))
            }
        }

        public static func selectionField(_ id: Identifier, title: String, value: Property<String>, inputTextAlignment: TextAlignment = .right, action: Action<Void, Void, NoError>, accessory: UITableViewCellAccessoryType = .disclosureIndicator) -> Component {
            return Component(with: id) { visualDependencies in
                return .actionInput(
                    ActionInputCellViewModel(visualDependencies: visualDependencies,
                                             title: title,
                                             input: value,
                                             inputTextAlignment: inputTextAlignment,
                                             selected: action,
                                             accessory: accessory))
            }
        }

        public static func buttonField(_ id: Identifier, title: String, action: Action<Void, Void, NoError>) -> Component {
            return Component(with: id) { visualDependencies in
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

        public static func iconSelectionField(_ id: Identifier,
                                              icon: SignalProducer<UIImage, NoError>,
                                              title: String,
                                              titleStyle: UIViewStyle<UILabel>? = nil,
                                              value: Property<String>? = nil,
                                              action: Action<Void, Void, NoError>) -> Component {
            return Component(with: id) { visualDependencies in
                return .actionInput(
                    ActionInputCellViewModel(visualDependencies: visualDependencies,
                                             icon: icon,
                                             title: title,
                                             input: value,
                                             inputTextAlignment: .right,
                                             selected: action,
                                             titleStyle: titleStyle))
            }
        }

        public static func avatarSelectionField(_ id: Identifier,
                                                icon: SignalProducer<UIImage, NoError>,
                                                subIcon: UIImage?,
                                                title: Property<String>,
                                                input: Property<String>? = nil,
                                                isVertical: Bool = false,
                                                action: Action<Void, Void, NoError>,
                                                accessory: UITableViewCellAccessoryType = .disclosureIndicator,
                                                subtitleStyle: UIViewStyle<UILabel>? = nil,
                                                selectionStyle: UITableViewCellSelectionStyle = .gray) -> Component {
            return Component(with: id) { visualDependencies in
                return .actionInput(
                    ActionInputCellViewModel(visualDependencies: visualDependencies,
                                             icon: icon,
                                             subIcon: subIcon,
                                             iconStyle: .largeRoundAvatar,
                                             title: title,
                                             input: input,
                                             inputTextAlignment: .left,
                                             selected: action,
                                             accessory: accessory,
                                             subtitleStyle: subtitleStyle,
                                             isVertical: isVertical)
                )
            }
        }

        public static func segmentedField(_ id: Identifier, options: [SegmentedCellViewModel.Option], selection: MutableProperty<Int>) -> Component {
            return Component(with: id) { visualDependencies in
                return .segmentedInput(
                    SegmentedCellViewModel(options: options,
                                           selection: selection,
                                           visualDependencies: visualDependencies))
            }
        }

        public static func noteField(_ id: Identifier, placeholder: String, text: ValidatingProperty<String, InvalidInput>, addPhotosAction: Action<Void, Void, NoError>? = nil) -> Component {
            return Component(with: id) { visualDependencies in
                return .noteInput(
                    NoteInputCellViewModel(placeholder: placeholder,
                                           text: text,
                                           addPhotosAction: addPhotosAction,
                                           visualDependencies: visualDependencies))
            }
        }

        public static func note(_ id: Identifier, _ text: Property<String>, placeholder: String? = nil) -> Component {
            return Component(with: id) { visualDependencies in
                return .note(NoteCellViewModel(placeholder: placeholder,
                                               text: text,
                                               visualDependencies: visualDependencies))
            }
        }

        public static func textOptionsField(_ id: Identifier, items: Property<[String]>, selectionAction: Action<Int, Void, NoError>, spec: TextOptionsCellViewSpec, headline: String? = nil) -> Component {
            return Component(with: id) { visualDependencies in
                return .textOptionsInput(TextOptionsCellViewModel(items: items, selectionAction: selectionAction, headline: headline), spec)
            }
        }

        public static func imageOptionsField(_ id: Identifier, items: [UIImage], selectionAction: Action<Int, Void, NoError>, destructiveAction: Action<Int, Void, NoError>? = nil, spec: ImageOptionsCellViewSpec) -> Component {
            return Component(with: id) { visualDependencies in
                return .imageOptionsInput(ImageOptionsCellViewModel(items: items, selectionAction: selectionAction, destructiveAction: destructiveAction), spec)
            }
        }

        public static func toggle(_ id: Identifier, title: String, isOn: MutableProperty<Bool>, icon: UIImage? = nil, isEnabled: Property<Bool>? = nil) -> Component {
            return Component(with: id) { visualDependencies in
                return .toggle(
                    ToggleCellViewModel(title: title,
                                        isOn: isOn,
                                        icon: icon,
                                        isEnabled: isEnabled ?? Property(value: true),
                                        visualDependencies: visualDependencies))
            }
        }

        public static func imageField(_ id: Identifier, image: SignalProducer<UIImage, NoError>, imageSize: CGSize, imageAlignment: CellElementAlignment = .centered, isRounded: Bool = false, selected: Action<Void, Void, NoError>? = nil, leftIcon: SignalProducer<UIImage?, NoError> = .empty) -> Component {
            return Component(with: id) { visualDependencies in
                return .image(ImageCellViewModel(image: image,
                                                 imageSize: imageSize,
                                                 visualDependencies: visualDependencies,
                                                 imageAlignment: imageAlignment,
                                                 isRounded: isRounded,
                                                 selected: selected,
                                                 leftIcon: leftIcon))
            }
        }

        public static func activityIndicator(_ id: Identifier, isRefreshing: Property<Bool>) -> Component {
            return Component(with: id) { visualDependencies in
                return .activityIndicator(ActivityIndicatorCellViewModel(isRefreshing: isRefreshing),
                                          ActivityIndicatorCellViewSpec(cellStyle: visualDependencies.styles.backgroundTransparentColor))
            }
        }

        public static func titledList(_ id: Identifier, title: String, items: [TitledListItem]) -> Component {
            return Component(with: id) { visualDependencies in
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
            _ formId: Identifier,
            title: String,
            icon: SignalProducer<UIImage, NoError>? = nil,
            identifier: Int,
            in group: SelectionCellGroupViewModel,
            spec: SelectionCellViewSpec
        ) -> Component {
            return Component(with: formId) { visualDependencies in
                let viewModel = SelectionCellViewModel(title: title,
                                                       icon: icon,
                                                       identifier: identifier)
                return .selection(viewModel, group: group, spec: spec)
            }
        }

        public static func custom(_ id: Identifier, _ component: FormComponent) -> Component {
            return Component(with: id) { _ in component }
        }
    }
}
