import UIKit
import ReactiveSwift
import ReactiveCocoa
import Result

public final class LegacySelectionCellGroupViewModel {
    public var hasDisclosureAction: Bool {
        return discloseDetails != nil
    }

    private let (lifetime, token) = Lifetime.make()

    /// The unique identifier of the current selection in the group.
    private let selection: Property<Int?>

    /// Process a user selection of the given unique identifier.
    private let userSelected: Action<Int, Never, NoError>

    /// Request details for the selection item of the given unique identifier.
    ///
    /// The default implementation is `nil`. If any action is provided, `SelectionCell`
    /// would display a detail disclosure button with an alternative layout.
    private let discloseDetails: Action<Int, Never, NoError>?

    /// The identifier of the selection item that has triggered the running side effect of
    /// the group. `nil` if the group is not executing any side effect.
    private let processingId: MutableProperty<Int?>
    private let actionAvailability: Property<(userSelected: Bool, discloseDetails: Bool)>

    public init(selection: Property<Int?>, userSelected: Action<Int, Never, NoError>, discloseDetails: Action<Int, Never, NoError>?) {
        (self.selection, self.userSelected, self.discloseDetails) = (selection, userSelected, discloseDetails)
        processingId = MutableProperty(nil)
        actionAvailability = Property.combineLatest(userSelected.isEnabled,
                                                    discloseDetails?.isEnabled ?? Property(value: false))
            .map { $0 }
    }

    public func selected(forItemIdentifier identifier: Int) -> BindingTarget<()> {
        return BindingTarget(lifetime: lifetime) { [weak self] in
            guard let strongSelf = self, strongSelf.shouldStart(forIdentifier: identifier) else { return }
            strongSelf.userSelected.apply(identifier)
                .start { _ in strongSelf.complete() }
        }
    }

    public func disclosureButtonPressed(forItemIdentifier identifier: Int) -> BindingTarget<()> {
        return BindingTarget(lifetime: lifetime) { [weak self] in
            guard let strongSelf = self,
                let discloseDetails = strongSelf.discloseDetails,
                strongSelf.shouldStart(forIdentifier: identifier) else { return }
            discloseDetails.apply(identifier)
                .start { _ in strongSelf.complete() }
        }
    }

    public func controlAvailability(for identifier: Int, isFormEnabled: Property<Bool>) -> SignalProducer<SelectionCellStatus, NoError> {
        return SignalProducer
            .combineLatest(actionAvailability.producer,
                           isFormEnabled.producer,
                           selection.producer.map { $0 == identifier }.skipRepeats(),
                           processingId.producer.map { $0 == identifier }.skipRepeats())
            .map { arguments in
                let (actionAvailability, isFormEnabled, isSelected, isProcessing) = arguments
                if isProcessing {
                    return .processing(selected: isSelected)
                }

                if isFormEnabled && actionAvailability.userSelected {
                    return .enabled(selected: isSelected,
                                    isDisclosureEnabled: actionAvailability.discloseDetails)
                }

                return .disabled(selected: isSelected)
            }
    }

    private func shouldStart(forIdentifier id: Int) -> Bool {
        return processingId.modify { processingOrigin in
            if processingOrigin == nil {
                processingOrigin = id
                return true
            }
            return false
        }
    }

    private func complete() {
        processingId.value = nil
    }
}

public enum SelectionCellStatus {
    case enabled(selected: Bool, isDisclosureEnabled: Bool)
    case processing(selected: Bool)
    case disabled(selected: Bool)
}
