public enum FormComponent {
    case textInput(TextInputCellViewModel)
    case titledTextInput(TitledTextInputCellViewModel)
    case phoneTextInput(PhoneInputCellViewModel)
    case actionButton(ActionCellViewModel, ActionCellViewSpec)
    case facebookButton(FacebookCellViewModel)
    case description(DescriptionCellViewModel)
    case separator(SeparatorCellViewModel)
    case space(EmptySpaceCellViewModel)
    case actionInput(ActionInputCellViewModel)
    case actionIconInput(ActionIconInputCellViewModel)
    case actionDescription(ActionDescriptionCellViewModel)
    case toggle(ToggleCellViewModel)
    case segmentedInput(SegmentedCellViewModel)
    case selection(SelectionCellViewModel, group: SelectionCellGroup, spec: SelectionCellViewSpec)
    case noteInput(NoteInputCellViewModel)

    var viewModel: Any {
        switch self {
        case .textInput(let viewModel):
            return viewModel
        case .titledTextInput(let viewModel):
            return viewModel
        case .phoneTextInput(let viewModel):
            return viewModel
        case .actionButton(let viewModel, _):
            return viewModel
        case .facebookButton(let viewModel):
            return viewModel
        case .description(let viewModel):
            return viewModel
        case .separator(let viewModel):
            return viewModel
        case .space(let viewModel):
            return viewModel
        case .actionInput(let viewModel):
            return viewModel
        case .actionIconInput(let viewModel):
            return viewModel
        case .actionDescription(let viewModel):
            return viewModel
        case .toggle(let viewModel):
            return viewModel
        case .segmentedInput(let viewModel):
            return viewModel
        case .selection(let viewModel):
            return viewModel
        case .noteInput(let viewModel):
            return viewModel
        }
    }
}

extension FormComponent: Equatable {

    public static func ==(lhs: FormComponent, rhs: FormComponent) -> Bool {
        switch (lhs, rhs) {
        case let (.textInput(lhsViewModel), .textInput(rhsViewModel)):
            return lhsViewModel === rhsViewModel
        case let (.titledTextInput(lhsViewModel), .titledTextInput(rhsViewModel)):
            return lhsViewModel === rhsViewModel
        case let (.phoneTextInput(lhsViewModel), .phoneTextInput(rhsViewModel)):
            return lhsViewModel === rhsViewModel
        case let (.actionButton(lhsViewModel, _), .actionButton(rhsViewModel, _)):
            return lhsViewModel === rhsViewModel
        case let (.facebookButton(lhsViewModel), .facebookButton(rhsViewModel)):
            return lhsViewModel === rhsViewModel
        case let (.description(lhsViewModel), .description(rhsViewModel)):
            return lhsViewModel == rhsViewModel
        case let (.separator(lhsViewModel), .separator(rhsViewModel)):
            return lhsViewModel == rhsViewModel
        case let (.space(lhsViewModel), .space(rhsViewModel)):
            return lhsViewModel == rhsViewModel
        case let (.actionInput(lhsViewModel), .actionInput(rhsViewModel)):
            return lhsViewModel === rhsViewModel
        case let (.actionIconInput(lhsViewModel), .actionIconInput(rhsViewModel)):
            return lhsViewModel === rhsViewModel
        case let (.actionDescription(lhsViewModel), .actionDescription(rhsViewModel)):
            return lhsViewModel === rhsViewModel
        case let (.toggle(lhsViewModel), .toggle(rhsViewModel)):
            return lhsViewModel === rhsViewModel
        case let (.segmentedInput(lhsViewModel), .segmentedInput(rhsViewModel)):
            return lhsViewModel === rhsViewModel
        case let (.selection(lhsViewModel, lhsGroup, _), .selection(rhsViewModel, rhsGroup, _)):
            return lhsViewModel === rhsViewModel && lhsGroup === rhsGroup
        case let (.noteInput(lhsViewModel), .noteInput(rhsViewModel)):
            return lhsViewModel == rhsViewModel
        default:
            return false
        }
    }
}
