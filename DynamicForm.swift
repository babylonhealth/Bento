/* =============================================================================
 we are not using anything like a reactive array or similar, actually I 
 abandoned that approach because it's too hard to make changes in a form already 
 established considering we need to specify everything for the form, separators, 
 spaces, ..., and instead I went with the approach of React (from JS).

 Basically we have a state called ViewState that can potentially change, is 
 naturally reactive, and when it changes we re-calculate the entire form again 
 for that particular state which give us a new form and then we calculate a diff 
 between both forms to infer what really changed. This makes things a lot more 
 simpler because we just need to build the form for that particular state, 
 including or excluding a section, a button, ..., and we don't need to be 
 worried about which spaces and separators we need or not remove for the new 
 state and so on.

 ** Technical **

 Technically speaking we are using Dwifft to calculate diffs and our 
 FormComponents need to be Equatable to do so. We are currently following a 
 naive approach to implement equality. Internally we use a Renderer to calculate 
 our form (tree) for a specific view state.

 TL;DR It's much easier start with a clean slate instead of needing to 
 understand in which state we are and which transformations we need to do to end 
 with the desired state.

 ============================================================================ */

import ReactiveSwift
import enum Result.NoError
import Dwifft

struct Patch<T: Equatable> {

    enum Change<T> {
        case insert(index: Int, element: T)
        case delete(index: Int, element: T)

        fileprivate init(diff: DiffStep<T>) {
            switch diff {
            case let .insert(index, element): self = .insert(index: index, element: element)
            case let .delete(index, element): self = .delete(index: index, element: element)
            }
        }
    }

    let changes: [Change<T>]

    init(previous: [T], current: [T]) {
        changes = Dwifft.diff(previous, current).map(Patch.Change.init)
    }
}

struct FormRenderer<ViewState> {

    private class Cage {

        static var empty: Cage {
            return Cage([])
        }

        let components: [FormComponent]

        init(_ components: [FormComponent]) {
            self.components = components
        }
    }

    private let cage: Property<Cage>

    var components: Property<[FormComponent]> {
        return cage.map { $0.components }
    }

    init(viewState: Property<ViewState>, render: @escaping (ViewState) -> [FormComponent]) {

        cage = Property(initial: .empty, then:
            viewState
                .map(render)
                .producer
                .scan(Cage.empty) { cage, components in
                    return Cage(Dwifft.apply(diff: Dwifft.diff(cage.components, components), toArray: cage.components))
            })
    }
}

protocol DynamicForm: Form {
    var changes: Signal<(previous: [FormComponent], current: [FormComponent], patch: Patch<FormComponent>), NoError> { get }
}

extension DynamicForm {

    var changes: Signal<(previous: [FormComponent], current: [FormComponent], patch: Patch<FormComponent>), NoError> {
        // FIXME: Welp we need a `combinePrevious` that doesn't need an initial value.
        return components.signal
            .combinePrevious(components.value)
            .map{ (lhs, rhs) in (lhs, rhs, Patch(previous: lhs, current: rhs)) }
    }
}
