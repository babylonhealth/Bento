public enum FormComponent {
    case textInput(TextInputCellViewModel)
    case titledTextInput(TitledTextInputCellViewModel)
    case phoneTextInput(PhoneInputCellViewModel)
    case actionButton(ActionCellViewModel, ActionCellViewSpec)
    case facebookButton(FacebookCellViewModel)
    case description(DescriptionCellViewModel)
    case textOptionsInput(TextOptionsCellViewModel, TextOptionsCellViewSpec)
    case imageOptionsInput(ImageOptionsCellViewModel, ImageOptionsCellViewSpec)
    case space(EmptySpaceCellViewModel)
    case actionInput(ActionInputCellViewModel)
    case actionDescription(ActionDescriptionCellViewModel)
    case toggle(ToggleCellViewModel)
    case segmentedInput(SegmentedCellViewModel)
    case selection(SelectionCellViewModel, group: SelectionCellGroupViewModel, spec: SelectionCellViewSpec)
    case noteInput(NoteInputCellViewModel)
    case image(ImageCellViewModel)
    case activityIndicator(ActivityIndicatorCellViewModel, ActivityIndicatorCellViewSpec)

    /// Indicates whether the component defines a section. `FormViewController` uses
    /// `definesSection` to determine the visibility of cell separators.
    ///
    /// - note: If there are multiple section-defining components in a row, no separator
    ///         would be displayed between them.
    var definesSection: Bool {
        switch self {
        case .description, .actionDescription, .space, .facebookButton, .actionButton:
            return true
        default:
            return false
        }
    }

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
        case let .textOptionsInput(viewModel, _):
            return viewModel
        case let .imageOptionsInput(viewModel, _):
            return viewModel
        case .space(let viewModel):
            return viewModel
        case .actionInput(let viewModel):
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
        case .image(let viewModel):
            return viewModel
        case let .activityIndicator(viewModel, _):
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
            return lhsViewModel === rhsViewModel
        case let (.textOptionsInput(lhsViewModel, _), .textOptionsInput(rhsViewModel, _)):
            return lhsViewModel === rhsViewModel
        case let (.imageOptionsInput(lhsViewModel, _), .imageOptionsInput(rhsViewModel, _)):
            return lhsViewModel === rhsViewModel
        case let (.space(lhsViewModel), .space(rhsViewModel)):
            return lhsViewModel == rhsViewModel
        case let (.actionInput(lhsViewModel), .actionInput(rhsViewModel)):
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
            return lhsViewModel === rhsViewModel
        case let (.image(lhsViewModel), .image(rhsViewModel)):
            return lhsViewModel === rhsViewModel
        case let (.activityIndicator(lhsViewModel, _), .activityIndicator(rhsViewModel, _)):
            return lhsViewModel === rhsViewModel
        default:
            return false
        }
    }
}
