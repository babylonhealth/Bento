import UIKit

final class FormTableViewDataSource: NSObject, UITableViewDataSource {

    var components: [FormComponent] = []

    func setupTable(tableView: UITableView) {
        tableView.register(TextInputCell.self)
        tableView.register(TitledTextInputCell.self)
        tableView.register(PhoneInputCell.self)
        tableView.register(SeparatorCell.self)
        tableView.register(EmptySpaceCell.self)
        tableView.register(DescriptionCell.self)
        tableView.register(ActionCell.self)
        tableView.register(ActionInputCell.self)
        tableView.register(ActionDescriptionCell.self)
        tableView.register(FacebookCell.self)
        tableView.register(ToggleCell.self)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
    }

    func update(tableView: UITableView, with components: [FormComponent]) {
        self.components = components
        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return components.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return mapViewModelToCell(fromTableView: tableView, atIndexPath: indexPath)
    }

    private func mapViewModelToCell(fromTableView tableView: UITableView, atIndexPath indexPath: IndexPath) -> UITableViewCell {

        let cellViewModel = components[indexPath.row]

        switch cellViewModel {
        case .textInput(let viewModel):
            let cell: TextInputCell = tableView.dequeueReusableCell(for: indexPath)
            cell.setup(viewModel: viewModel)
            return cell
        case .titledTextInput(let viewModel):
            let cell: TitledTextInputCell = tableView.dequeueReusableCell(for: indexPath)
            cell.setup(viewModel: viewModel)
            return cell
        case .phoneTextInput(let viewModel):
            let cell: PhoneInputCell = tableView.dequeueReusableCell(for: indexPath)
            cell.setup(viewModel: viewModel)
            return cell
        case .separator(let viewModel):
            let cell: SeparatorCell = tableView.dequeueReusableCell(for: indexPath)
            cell.setup(viewModel: viewModel)
            return cell
        case .space(let viewModel):
            let cell: EmptySpaceCell = tableView.dequeueReusableCell(for: indexPath)
            cell.setup(viewModel: viewModel)
            return cell
        case .description(let viewModel):
            let cell: DescriptionCell = tableView.dequeueReusableCell(for: indexPath)
            cell.setup(viewModel: viewModel)
            return cell
        case .facebookButton(let viewModel):
            let cell: FacebookCell = tableView.dequeueReusableCell(for: indexPath)
            cell.setup(viewModel: viewModel)
            return cell
        case .actionButton(let viewModel):
            let cell: ActionCell = tableView.dequeueReusableCell(for: indexPath)
            cell.setup(viewModel: viewModel)
            return cell
        case .actionInput(let viewModel):
            let cell: ActionInputCell = tableView.dequeueReusableCell(for: indexPath)
            cell.setup(viewModel: viewModel)
            return cell
        case .actionDescription(let viewModel):
            let cell: ActionDescriptionCell = tableView.dequeueReusableCell(for: indexPath)
            cell.setup(viewModel: viewModel)
            return cell
        case .toggle(let viewModel):
            let cell: ToggleCell = tableView.dequeueReusableCell(for: indexPath)
            cell.setup(viewModel: viewModel)
            return cell
        }
    }
    
    convenience init(tableView: UITableView, components: [FormComponent]) {
        self.init()
        setupTable(tableView: tableView)
        update(tableView: tableView, with: components)
    }
}
