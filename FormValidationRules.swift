import ReactiveSwift
import PhoneNumberKit
import BabylonFoundation

enum ValidationStatus<Error: Swift.Error> {
    case valid
    case invalid(Error)

    var isInvalid: Bool {
        switch self {
        case .valid: return false
        case .invalid(_): return true
        }
    }

    var error: Error? {
        switch self {
        case .valid: return nil
        case .invalid(let error): return error
        }
    }
}

public struct PropertyValidator<Error: Swift.Error> {

    let status: Property<ValidationStatus<Error>>

    init<T>(_ property: ValidatingProperty<T, Error>) {
        status = property.result.map {
            switch $0 {
            case .valid:
                return .valid
            case .coerced:
                return .valid
            case .invalid(_, let error):
                return .invalid(error)
            }
        }
    }
}

extension ValidatingProperty {

    public var validator: PropertyValidator<ValidationError> {
        return PropertyValidator(self)
    }
}

public protocol ValidationErrorDescriptionProtocol: Swift.Error {
    var reason: String { get }
}

public protocol FormProperties {
    associatedtype Error: Swift.Error

    var validators: [PropertyValidator<Error>] { get }
}

extension FormProperties {

    func isFormValid() -> Property<Bool> {
        return validators |> isFormValid
    }

    private func isFormValid(_ formFields: [PropertyValidator<Error>]) -> Property<Bool> {

        let reduceIntoOblivion: ([ValidationStatus<Error>]) -> Bool = { result in
            result.map { $0.isInvalid == false }.reduce(true) { $0 && $1 }
        }

        let combinedFields = formFields.map { $0.status.producer } |> SignalProducer.combineLatest
        let isFormValid = combinedFields.map(reduceIntoOblivion)

        return Property(initial: false, then: isFormValid)
    }

}

extension FormProperties where Error: ValidationErrorDescriptionProtocol {

    public func failureReason() -> String? {
        return validators |> failureReason
    }

    private func failureReason(_ formFields: [PropertyValidator<Error>]) -> String? {
        return formFields
            .map { $0.status.value.error }
            .flatMap { $0 }
            .map { $0.reason }
            .reduce { $0 + "\n" + $1 }
    }
}

public struct InvalidInput: Error {
    public let reason: String

    public init(reason: String) {
        self.reason = reason
    }
}

extension InvalidInput: ValidationErrorDescriptionProtocol {}

private func emailValidation() -> String {
    return "[a-zA-Z0-9\\+\\.\\_\\%\\-\\+]{1,256}" + "\\@" + "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,64}" +
        "(" + "\\." + "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,25}" + ")+"
}

private func passwordValidation() -> String {
    return "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d).+$"
}

private func max12Characters() -> String {
    return "^[\\da-zA-Z]{1,12}$"
}

private func nonEmptyValidation() -> String {
    return "^(?!\\s*$).+"
}

private func noValidation() -> String {
    return ".*?"
}

private func evaluate(_ input: String) -> (String) -> Bool {
    return { regex in NSPredicate(format:"SELF MATCHES %@", regex).evaluate(with: input) }
}

private func toValidatorOutput<T>(_ errorMessage: String) -> (Bool) -> ValidatingProperty<T, InvalidInput>.Decision {
    return { isValid in isValid ? .valid : .invalid(InvalidInput(reason: errorMessage)) }
}

import Result

// Used as a namespace (an enum without cases cannot be instantiated)
public enum FormValidationRules {
    public static func phoneNumberValidatingProperty(initialValue: String = "", invalidMessage: String
        ) -> ValidatingProperty<String, InvalidInput> {

        func evaluate(_ input: String) -> Bool {
            return Result<PhoneNumber, PhoneNumberError> { try PhoneNumberKit().parse(input) }.value != nil
        }

        return ValidatingProperty(initialValue, { evaluate($0) |> toValidatorOutput(invalidMessage) })
    }

    public static func conditionallyPhoneNumberValidatingProperty<P>(initialValue: String = "",
                                                                     validateIf needsValidation: P,
                                                                     invalidMessage: String
        ) -> ValidatingProperty<String, InvalidInput> where P: PropertyProtocol, P.Value == Bool {

        func evaluate(_ input: String) -> Bool {
            return Result<PhoneNumber, PhoneNumberError> { try PhoneNumberKit().parse(input) }.value != nil
        }

        return conditionallyValidatingProperty(initialValue: initialValue,
                                               validateIf: needsValidation,
                                               validation: evaluate,
                                               invalidMessage: invalidMessage)
    }

    public static func emailValidatingProperty(initialValue: String = "", invalidMessage: String = LocalizationUI.Error.emailInvalidErrorMessage) -> ValidatingProperty<String, InvalidInput> {
        return makeValidatingProperty(regex: emailValidation(), initialValue: initialValue, invalidMessage: invalidMessage)
    }

    public static func passwordValidatingProperty(initialValue: String = "", invalidMessage: String = LocalizationUI.Error.passwordInvalidErrorMessage) -> ValidatingProperty<String, InvalidInput> {
        return makeValidatingProperty(regex: passwordValidation(), initialValue: initialValue, invalidMessage: invalidMessage)
    }

    public static func membershipValidatingProperty(initialValue: String = "", invalidMessage: String = LocalizationUI.Error.membershipInvalidErrorMessage) -> ValidatingProperty<String, InvalidInput> {
        return makeValidatingProperty(regex: max12Characters(), initialValue: initialValue, invalidMessage: invalidMessage)
    }

    public static func nonEmptyValidatingProperty(initialValue: String = "", invalidMessage: String) -> ValidatingProperty<String, InvalidInput> {
        return makeValidatingProperty(regex: nonEmptyValidation(), initialValue: initialValue, invalidMessage: invalidMessage)
    }

    public static func noValidationValidatingProperty(initialValue: String = "") -> ValidatingProperty<String, InvalidInput> {
        return makeValidatingProperty(regex: noValidation(), initialValue: initialValue, invalidMessage: "")
    }

    public static func nonOptionalValidatingProperty<T>(initialValue: T? = nil, invalidMessage: String) -> ValidatingProperty<T?, InvalidInput> {

        func evaluate(_ input: T?) -> Bool {
            return input != nil
        }

        return ValidatingProperty(initialValue, { evaluate($0) |> toValidatorOutput(invalidMessage) })
    }

    public static func conditionallyNonOptionalValidatingProperty<P, T>(
        initialValue: T? = nil,
        validateIf needsValidation: P,
        invalidMessage: String
        ) -> ValidatingProperty<T?, InvalidInput> where P: PropertyProtocol, P.Value == Bool {

        // NOTE: This is done manually until we get proper generics (Swift 4)
        return ValidatingProperty(initialValue, with: needsValidation) { (value, needsValidation) in
            guard needsValidation else { return .valid }
            return value != nil ? .valid : .invalid(InvalidInput(reason: invalidMessage))
        }
    }

    public static func conditionallyNonEmptyValidatingProperty<P>(
        initialValue: String = "",
        validateIf needsValidation: P,
        invalidMessage: String
        ) -> ValidatingProperty<String, InvalidInput> where P: PropertyProtocol, P.Value == Bool {

        return conditionallyValidatingProperty(initialValue: initialValue,
                                               validateIf: needsValidation,
                                               validation: { $0.isEmpty == false },
                                               invalidMessage: invalidMessage)
    }

    private static func conditionallyValidatingProperty<T, P>(
        initialValue: T,
        validateIf needsValidation: P,
        validation: @escaping (T) -> Bool,
        invalidMessage: String
        ) -> ValidatingProperty<T, InvalidInput> where P: PropertyProtocol, P.Value == Bool {

        return ValidatingProperty(initialValue, with: needsValidation) { (value, needsValidation) in
            guard needsValidation else { return .valid }

            return validation(value) ? .valid : .invalid(InvalidInput(reason: invalidMessage))
        }
    }

    private static func makeValidatingProperty(regex: String, initialValue: String, invalidMessage: String) -> ValidatingProperty<String, InvalidInput> {
        return ValidatingProperty(initialValue, { regex |> evaluate($0) |> toValidatorOutput(invalidMessage) })
    }
}

public struct PhoneProperty {
    private let combinedFields: ValidatingProperty<String, InvalidInput>
    public let countryCode: MutableProperty<String>
    public let number = MutableProperty<String>("")
    public var validator: PropertyValidator<InvalidInput> {
        return combinedFields.validator
    }
    public init(region: RegionDTO, invalidMessage: String) {
        countryCode = MutableProperty(region.phoneCountryCode)
        combinedFields = FormValidationRules.phoneNumberValidatingProperty(invalidMessage: invalidMessage)

        combinedFields <~ Property.combineLatest(countryCode, number)
            .producer
            .debounce(0.2, on: QueueScheduler(qos: .userInitiated))
            .map { [$0, $1].joined(separator: " ") }
    }
}

