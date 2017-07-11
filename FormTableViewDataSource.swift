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

import UIKit
import ReactiveSwift
import Dwifft

public protocol FormCellConfigurator: class {
    func configure<Cell: UITableViewCell>(_ cell: Cell)
}

public final class FormTableViewDataSource: NSObject, UITableViewDataSource {
    internal private(set) var components: [FormComponent]
    private weak var configurator: FormCellConfigurator?

    private init(configurator: FormCellConfigurator?) {
        self.components = []
        self.configurator = configurator
        super.init()
    }

    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return components.count
    }

    private func configure<Cell: UITableViewCell>(_ dequeue: (IndexPath) -> Cell, for indexPath: IndexPath) -> Cell {
        let cell = dequeue(indexPath)
        configurator?.configure(cell)
        return cell
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellViewModel = components[indexPath.row]

        switch cellViewModel {
        case .textInput(let viewModel):
            let cell: TextInputCell = configure(tableView.dequeueReusableCell(for:), for: indexPath)
            cell.setup(viewModel: viewModel)
            return cell
        case .titledTextInput(let viewModel):
            let cell: TitledTextInputCell = configure(tableView.dequeueReusableCell(for:), for: indexPath)
            cell.setup(viewModel: viewModel)
            return cell
        case .phoneTextInput(let viewModel):
            let cell: PhoneInputCell = configure(tableView.dequeueReusableCell(for:), for: indexPath)
            cell.setup(viewModel: viewModel)
            return cell
        case .separator(let viewModel):
            let cell: SeparatorCell = configure(tableView.dequeueReusableCell(for:), for: indexPath)
            cell.setup(viewModel: viewModel)
            return cell
        case .space(let viewModel):
            let cell: EmptySpaceCell = configure(tableView.dequeueReusableCell(for:), for: indexPath)
            cell.setup(viewModel: viewModel)
            return cell
        case .description(let viewModel):
            let cell: DescriptionCell = configure(tableView.dequeueReusableCell(for:), for: indexPath)
            cell.setup(viewModel: viewModel)
            return cell
        case .facebookButton(let viewModel):
            let cell: FacebookCell = configure(tableView.dequeueReusableCell(for:), for: indexPath)
            cell.setup(viewModel: viewModel)
            return cell
        case .actionButton(let viewModel, let spec):
            let cell: ActionCell = configure(tableView.dequeueReusableCell(for:), for: indexPath)
            cell.setup(viewModel: viewModel, spec: spec)
            return cell
        case .actionInput(let viewModel):
            let cell: ActionInputCell = configure(tableView.dequeueReusableCell(for:), for: indexPath)
            cell.setup(viewModel: viewModel)
            return cell
        case .actionIconInput(let viewModel):
            let cell: ActionIconInputCell = configure(tableView.dequeueReusableCell(for:), for: indexPath)
            cell.setup(viewModel: viewModel)
            return cell
        case .actionDescription(let viewModel):
            let cell: ActionDescriptionCell = configure(tableView.dequeueReusableCell(for:), for: indexPath)
            cell.setup(viewModel: viewModel)
            return cell
        case .toggle(let viewModel):
            let cell: ToggleCell = configure(tableView.dequeueReusableCell(for:), for: indexPath)
            cell.setup(viewModel: viewModel)
            return cell
        case .segmentedInput(let viewModel):
            let cell: SegmentedCell = configure(tableView.dequeueReusableCell(for:), for: indexPath)
            cell.setup(viewModel: viewModel)
            return cell
        case let .selection(item, group, spec):
            let cell: SelectionCell = tableView.dequeueReusableCell(for: indexPath)
            cell.configure(for: item, in: group, spec: spec)
            return cell
        }
    }

    public static func bind(_ tableView: UITableView, to components: Property<[FormComponent]>, configurator: FormCellConfigurator? = nil) -> FormTableViewDataSource {
        tableView.register(TextInputCell.self)
        tableView.register(TitledTextInputCell.self)
        tableView.register(PhoneInputCell.self)
        tableView.register(SeparatorCell.self)
        tableView.register(EmptySpaceCell.self)
        tableView.register(DescriptionCell.self)
        tableView.register(ActionCell.self)
        tableView.register(ActionInputCell.self)
        tableView.register(ActionIconInputCell.self)
        tableView.register(ActionDescriptionCell.self)
        tableView.register(FacebookCell.self)
        tableView.register(ToggleCell.self)
        tableView.register(SegmentedCell.self)
        tableView.register(SelectionCell.self)

        let dataSource = FormTableViewDataSource(configurator: configurator)
        tableView.dataSource = dataSource

        // Reset the table view internal state.
        tableView.reloadData()

        components.producer
            .combinePrevious([])
            .take(duringLifetimeOf: tableView)
            .observe(on: UIScheduler())
            .startWithValues { [weak tableView] previous, current in
                guard let tableView = tableView else { return }
                dataSource.components = current

                // Dismiss any first responder to avoid view corruption.
                tableView.endEditing(true)

                tableView.beginUpdates()
                defer { tableView.endUpdates() }

                for step in Dwifft.diff(previous, current) {
                    switch step {
                    case let .insert(index, _):
                        tableView.insertRows(at: [IndexPath(row: index, section: 0)], with: .fade)

                    case let .delete(index, _):
                        tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .fade)
                    }
                }
            }

        return dataSource
    }
}
