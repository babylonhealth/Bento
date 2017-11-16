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
    internal let components: [Component]

    public static var empty: FormBuilder {
        return FormBuilder()
    }

    private init(_ components: [Component] = []) {
        self.components = components
    }

    public func build(with visualDependencies: VisualDependenciesProtocol) -> FormTree<Int> {
        return FormBuilderV2<Int>(components: components.enumerated().map { $1.wrapped($0) })
            .build(with: visualDependencies)
    }

    public static func |-+(builder: FormBuilder, component: Component) -> FormBuilder {
        return FormBuilder(builder.components + [component])
    }

    public static func |-* (builder: FormBuilder, other: FormBuilderV2<Int>) -> FormBuilder {
        return FormBuilder(builder.components + other.components.map { component in Component { _ in component } })
    }

    public static func |-* (builder: FormBuilder, components: [FormBuilder.Component]) -> FormBuilder {
        return FormBuilder(builder.components + components)
    }

    public static func |-* (builder: FormBuilder, other: FormBuilder) -> FormBuilder {
        return FormBuilder(builder.components + other.components)
    }

    public static func |-* (builder: FormBuilder, generator: () -> FormBuilder) -> FormBuilder {
        return FormBuilder(builder.components + generator().components)
    }

    public static func |-? (builder: FormBuilder, validator: Validator<FormBuilder>) -> FormBuilder {
        guard validator.condition() else { return builder }
        return FormBuilder(builder.components + validator.generator(.empty).components)
    }

    public static func |-| (builder: FormBuilder, height: Float) -> FormBuilder {
        return FormBuilder(builder.components + [.space(height: height)])
    }
}

extension FormBuilder {

    public struct Component {
        fileprivate let wrapped: (Int) -> FormBuilderV2<Int>.Component

        public init(_ component: @escaping (Int) -> FormBuilderV2<Int>.Component) {
            wrapped = component
        }

        public static func space(height: Float) -> Component {
            return Component { _ in .space(height: height) }
        }

        public static func header(text: String) -> Component {
            return Component { .header($0, text: text) }
        }

        public static func headline(text: String) -> Component {
            return Component { .headline($0, text: text) }
        }

        public static func description(_ type: DescriptionCellType, text: String, selected: Action<Void, Void, NoError>? = nil) -> Component {
            return Component { .description($0, type, text: text, selected: selected) }
        }

        public static func actionDescription(_ description: NSAttributedString, action: Action<Void, Void, NoError>) -> Component {
            return Component {
                return .actionDescription($0, description, action: action)
            }
        }

        public static func facebookButton(title: String, action: Action<Void, Void, NoError>) -> Component {
            return Component {
                return .facebookButton($0, title: title, action: action)
            }
        }

        public static func primaryButton(text: String, action: Action<Void, Void, NoError>) -> Component {
            return Component {
                return .primaryButton($0, text: text, action: action)
            }
        }

        public static func secondaryButton(text: String, hasDynamicHeight: Bool = false, isDestructive: Bool = false, action: Action<Void, Void, NoError>) -> Component {
            return Component {
                return .secondaryButton($0, text: text, hasDynamicHeight: hasDynamicHeight, isDestructive: isDestructive, action: action)
            }
        }

        public static func cellButton(text: String,
                                      hasDynamicHeight: Bool = false,
                                      action: Action<Void, Void, NoError>,
                                      buttonMargins: CGFloat) -> Component {
            return Component {
                return .cellButton($0, text: text, hasDynamicHeight: hasDynamicHeight, action: action, buttonMargins: buttonMargins)
            }
        }

        public static func textField(
            icon: SignalProducer<UIImage, NoError>? = nil,
            placeholder: String,
            text: ValidatingProperty<String, InvalidInput>,
            clearsOnBeginEditing: Bool = false,
            autocapitalizationType: UITextAutocapitalizationType = .sentences,
            autocorrectionType: UITextAutocorrectionType = .default,
            keyboardType: UIKeyboardType = .default
        ) -> Component {
            return Component {
                return .textField($0, icon: icon, placeholder: placeholder, text: text, clearsOnBeginEditing: clearsOnBeginEditing, autocapitalizationType: autocapitalizationType, autocorrectionType: autocorrectionType, keyboardType: keyboardType)
            }
        }

        public static func passwordField(placeholder: String, text: ValidatingProperty<String, InvalidInput>) -> Component {
            return Component {
                return .passwordField($0, placeholder: placeholder, text: text)
            }
        }

        public static func titledPasswordField(title: String, placeholder: String, text: ValidatingProperty<String, InvalidInput>) -> Component {
            return Component {
                return .titledPasswordField($0, title: title, placeholder: placeholder, text: text)
            }
        }

        public static func titledTextField(title: String,
                                           placeholder: String,
                                           text: ValidatingProperty<String, InvalidInput>,
                                           isEnabled: Property<Bool> = Property(value: true),
                                           autocapitalizationType: UITextAutocapitalizationType = .sentences,
                                           autocorrectionType: UITextAutocorrectionType = .default,
                                           keyboardType: UIKeyboardType = .default ) -> Component {

            return Component {
                return .titledTextField($0, title: title, placeholder: placeholder, text: text, isEnabled: isEnabled, autocapitalizationType: autocapitalizationType, autocorrectionType: autocorrectionType, keyboardType: keyboardType)
            }
        }

        public static func phoneTextField(title: String, placeholder: String, countryCode: MutableProperty<String>, phoneNumber: MutableProperty<String>) -> Component {
            return Component {
                return .phoneTextField($0, title: title, placeholder: placeholder, countryCode: countryCode, phoneNumber: phoneNumber)
            }
        }

        public static func selectionField(title: String, value: Property<String>, inputTextAlignment: TextAlignment = .right, action: Action<Void, Void, NoError>, accessory: UITableViewCellAccessoryType = .disclosureIndicator) -> Component {
            return Component {
                return .selectionField($0, title: title, value: value, inputTextAlignment: inputTextAlignment, action: action, accessory: accessory)
            }
        }

        public static func buttonField(title: String, action: Action<Void, Void, NoError>) -> Component {
            return Component {
                return .buttonField($0, title: title, action: action)
            }
        }

        public static func iconSelectionField(icon: SignalProducer<UIImage, NoError>,
                                              title: String,
                                              titleStyle: UIViewStyle<UILabel>? = nil,
                                              value: Property<String>? = nil,
                                              action: Action<Void, Void, NoError>) -> Component {
            return Component {
                return .iconSelectionField($0, icon: icon, title: title, titleStyle: titleStyle, value: value, action: action)
            }
        }

        public static func avatarSelectionField(icon: SignalProducer<UIImage, NoError>, subIcon: UIImage?, title: Property<String>, input: Property<String>? = nil, isVertical: Bool = false, action: Action<Void, Void, NoError>, accessory: UITableViewCellAccessoryType = .disclosureIndicator, subtitleStyle: UIViewStyle<UILabel>? = nil, selectionStyle: UITableViewCellSelectionStyle = .gray) -> Component {
            return Component {
                return .avatarSelectionField($0, icon: icon, subIcon: subIcon, title: title, input: input, isVertical: isVertical, action: action, accessory: accessory, subtitleStyle: subtitleStyle, selectionStyle: selectionStyle)
            }
        }

        public static func segmentedField(options: [SegmentedCellViewModel.Option], selection: MutableProperty<Int>) -> Component {
            return Component {
                return .segmentedField($0, options: options, selection: selection)
            }
        }

        public static func noteField(placeholder: String, text: ValidatingProperty<String, InvalidInput>, addPhotosAction: Action<Void, Void, NoError>? = nil) -> Component {
            return Component {
                return .noteField($0, placeholder: placeholder, text: text, addPhotosAction: addPhotosAction)
           }
        }


        public static func note(_ text: Property<String>, placeholder: String? = nil) -> Component {
            return Component {
                return .note($0, text, placeholder: placeholder)
            }
        }

        public static func textOptionsField(items: Property<[String]>, selectionAction: Action<Int, Void, NoError>, spec: TextOptionsCellViewSpec, headline: String? = nil) -> Component {
            return Component {
                return .textOptionsField($0, items: items, selectionAction: selectionAction, spec: spec, headline: headline)
            }
        }

        public static func imageOptionsField(items: [UIImage], selectionAction: Action<Int, Void, NoError>, destructiveAction: Action<Int, Void, NoError>? = nil, spec: ImageOptionsCellViewSpec) -> Component {
            return Component {
                return .imageOptionsField($0, items: items, selectionAction: selectionAction, destructiveAction: destructiveAction, spec: spec)
            }
        }

        public static func toggle(title: String, isOn: MutableProperty<Bool>, icon: UIImage? = nil, isEnabled: Property<Bool>? = nil) -> Component {
            return Component {
                return .toggle($0, title: title, isOn: isOn, icon: icon, isEnabled: isEnabled)
            }
        }

        public static func imageField(image: SignalProducer<UIImage, NoError>, imageSize: CGSize, imageAlignment: CellElementAlignment = .centered, isRounded: Bool = false, selected: Action<Void, Void, NoError>? = nil, leftIcon: SignalProducer<UIImage?, NoError> = .empty) -> Component {
            return Component {
                return .imageField($0, image: image, imageSize: imageSize, imageAlignment: imageAlignment, isRounded: isRounded, selected: selected, leftIcon: leftIcon)
            }
        }

        public static func activityIndicator(isRefreshing: Property<Bool>) -> Component {
            return Component {
                return .activityIndicator($0, isRefreshing: isRefreshing)
            }
        }

        public static func titledList(title: String, items: [TitledListItem]) -> Component {
            return Component {
                return .titledList($0, title: title, items: items)
            }
        }

        public static func multiselectionItem(
            title: String,
            icon: SignalProducer<UIImage, NoError>? = nil,
            identifier: Int,
            in group: SelectionCellGroupViewModel,
            spec: SelectionCellViewSpec
        ) -> Component {
            return Component {
                return .multiselectionItem($0, title: title, icon: icon, identifier: identifier, in: group, spec: spec)
            }
        }

        public static func custom(_ component: FormComponent) -> Component {
            return Component { .custom($0, component) }
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
