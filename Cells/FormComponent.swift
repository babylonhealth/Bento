enum FormComponent {
    case textInput(TextInputCellViewModel)
    case titledTextInput(TitledTextInputCellViewModel)
    case phoneTextInput(PhoneInputCellViewModel)
    case actionButton(ActionCellViewModel)
    case facebookButton(FacebookCellViewModel)
    case description(DescriptionCellViewModel)
    case separator(SeparatorCellViewModel)
    case space(EmptySpaceCellViewModel)
    case actionInput(ActionInputCellViewModel)
    case actionDescription(ActionDescriptionCellViewModel)
    case toggle(ToggleCellViewModel)

    private var viewModel: Any {
        switch self {
        case .textInput(let viewModel):
            return viewModel
        case .titledTextInput(let viewModel):
            return viewModel
        case .phoneTextInput(let viewModel):
            return viewModel
        case .actionButton(let viewModel):
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
        case .actionDescription(let viewModel):
            return viewModel
        case .toggle(let viewModel):
            return viewModel
        }
    }

    var focusable: Focusable? {
        return viewModel as? Focusable
    }
    
    var interactable: Interactable? {
        return viewModel as? Interactable
    }
    
    var selectable: Selectable? {
        return viewModel as? Selectable
    }

    var textEditable: TextEditable? {
        return viewModel as? TextEditable
    }
}

extension FormComponent: Equatable {

    static func ==(lhs: FormComponent, rhs: FormComponent) -> Bool {
        switch (lhs, rhs) {
        case let (.textInput(lhsViewModel), .textInput(rhsViewModel)):
            return lhsViewModel.placeholder.hash == rhsViewModel.placeholder.hash
        case let (.titledTextInput(lhsViewModel), .titledTextInput(rhsViewModel)):
            return lhsViewModel.placeholder.hash == rhsViewModel.placeholder.hash
                && lhsViewModel.title.hash == rhsViewModel.title.hash
        case let (.phoneTextInput(lhsViewModel), .phoneTextInput(rhsViewModel)):
            return lhsViewModel.placeholder.hash == rhsViewModel.placeholder.hash
                && lhsViewModel.title.hash == rhsViewModel.title.hash
        case let (.actionButton(lhsViewModel), .actionButton(rhsViewModel)):
            return lhsViewModel.title == rhsViewModel.title
        case let (.facebookButton(lhsViewModel), .facebookButton(rhsViewModel)):
            return lhsViewModel.title == rhsViewModel.title
        case let (.description(lhsViewModel), .description(rhsViewModel)):
            return lhsViewModel.text == rhsViewModel.text
                && lhsViewModel.type == rhsViewModel.type
        case let (.separator(lhsViewModel), .separator(rhsViewModel)):
            return lhsViewModel.width == rhsViewModel.width
                && lhsViewModel.isFullCell == rhsViewModel.isFullCell
        case let (.space(lhsViewModel), .space(rhsViewModel)):
            return lhsViewModel.height == rhsViewModel.height
        case let (.actionInput(lhsViewModel), .actionInput(rhsViewModel)):
            return lhsViewModel.title == rhsViewModel.title
        case let (.actionDescription(lhsViewModel), .actionDescription(rhsViewModel)):
            return lhsViewModel.title == rhsViewModel.title
        case let (.toggle(lhsViewModel), .toggle(rhsViewModel)):
            return lhsViewModel.title == rhsViewModel.title
        case (.textInput, _),
             (.titledTextInput, _),
             (.phoneTextInput, _),
             (.actionButton, _),
             (.facebookButton, _),
             (.description, _),
             (.separator, _),
             (.space, _),
             (.actionInput, _),
             (.actionDescription, _),
             (.toggle, _):
            return false
        }
    }
}
