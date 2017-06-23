import ReactiveSwift
import enum Result.NoError

public struct FocusableController {
    let focusableComponents: Property<[Focusable]>

    let focusedComponent: Property<FormComponent?>

    private let autoFocusDisposable: Atomic<Disposable?> = Atomic(nil)

    public init(components: Property<[FormComponent]>) {

        focusableComponents = components.map { $0.flatMap { $0.focusable } }

        func generateActivationSignals(with components: [FormComponent]) -> SignalProducer<FormComponent, NoError> {
            let activationSignals = components.flatMap { component in
                return component.focusable?.isFocused
                    .producer
                    .filter { $0 }
                    .map { _ in component }
            }
            return SignalProducer.merge(activationSignals)
        }

        let focusedComponentProducer = components.producer
            .flatMapLatest(generateActivationSignals)
            .map(Optional.init)
            .throttle(0.1, on: QueueScheduler.main)

        focusedComponent = Property(initial: nil, then: focusedComponentProducer)

        // TODO: [David] Move this reponsability to another entity (temporary workaround) 
        components
            .producer
            .startWithValues(FocusableController.reconfigureKeyboardReturnKey)
    }

    func setupAutoFocus() {

        func generateActivationSignals(with components: [Focusable]) -> Signal<(Int, [Focusable]), NoError> {
            let activationSignals = components.enumerated().map { offset, focusableElement in
                focusableElement.lostFocusReason
                    .skipRepeats()
                    .filter { $0 == .returnKey }
                    .map { _ in (offset, components) }
            }
            return Signal.merge(activationSignals)
                .throttle(0.1, on: QueueScheduler.main)
        }

        autoFocusDisposable.modify { disposable -> Void in
            guard disposable == nil else { return }

            self.focusableComponents
                .producer
                .flatMap(.latest, transform: generateActivationSignals)
                .startWithValues { offset, components in
                    components.suffix(from: offset.advanced(by: 1))
                        .first?
                        .isFocused
                        .value = true
                }
        }
    }

    func disableAutoFocus() {
        autoFocusDisposable.modify { disposable in
            guard disposable != nil else { return }
            disposable?.dispose()
            disposable = nil
        }
    }
    
    func focus(elementAt index: Int) {
        focusableComponents.value[index].isFocused.value = true
    }

    private static func reconfigureKeyboardReturnKey(in components: [FormComponent]) {
        components
            .reversed()
            .map { $0.textEditable }
            .flatMap { $0 }
            .enumerated()
            .forEach { index, component in component.keyboardReturnKeyType.value = index == 0 ? .done : .next }
    }
}
