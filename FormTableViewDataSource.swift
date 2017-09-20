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

public enum FormCellSeparatorVisibility {
    /// The separator should be invisible.
    case invisible

    /// The separator is visible and can be inset.
    case visible

    /// The separator is visible, but no inset should be applied.
    case visibleNoInset
}

public protocol FormCellConfigurator: class {
    func configure(_ cell: FormCell)
    func updateSeparatorsOfVisibleCells()
}

public final class FormTableViewDataSource: NSObject, UITableViewDataSource {
    private var components: [FormComponent]
    private weak var tableView: UITableView?
    private weak var configurator: FormCellConfigurator?

    public var indexOfPreferredRowForInitialFocus: Int? {
        if let startIndex = components.index(where: { $0.viewModel is FocusableFormComponent }) {
            let slice = components[startIndex ..< components.endIndex]
            guard let preferred = slice.index(where: { ($0.viewModel as? FocusableFormComponent)?.isPreferredForFocusing ?? false }) else {
                return startIndex
            }
            return preferred
        }
        return nil
    }

    public init(for tableView: UITableView) {
        self.components = []
        self.tableView = tableView
        super.init()
    }

    /// Compute the separator visibility for the specified cell.
    ///
    /// - parameters:
    ///   - row: The cell index.
    ///
    /// - returns: The separator visibility for the specified cell.
    public func separatorVisibility(forCellAt row: Int) -> FormCellSeparatorVisibility {
        let definesSection = components[row].definesSection
        let nextCellDefinesSection = row < components.count - 1 ? components[row + 1].definesSection : true

        switch (definesSection, nextCellDefinesSection) {
        case (true, true):
            return .invisible
        case (true, false), (false, true):
            return .visibleNoInset
        case (false, false):
            return .visible
        }
    }

    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return components.count
    }

    private func configure<Cell: FormCell>(_ dequeue: (IndexPath) -> Cell, for indexPath: IndexPath) -> Cell {
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
        case let .textOptionsInput(viewModel, viewSpec):
            let cell: TextOptionsCell = configure(tableView.dequeueReusableCell(for:), for: indexPath)
            cell.setup(viewModel: viewModel, viewSpec: viewSpec)
            return cell
        case let .imageOptionsInput(viewModel, viewSpec):
            let cell: ImageOptionsCell = configure(tableView.dequeueReusableCell(for:), for: indexPath)
            cell.setup(viewModel: viewModel, viewSpec: viewSpec)
            return cell
        case let .selection(item, group, spec):
            let cell: SelectionCell = configure(tableView.dequeueReusableCell(for:), for: indexPath)
            cell.configure(for: item, in: group, spec: spec)
            return cell
        case .noteInput(let viewModel):
            let cell: NoteInputCell = configure(tableView.dequeueReusableCell(for:), for: indexPath)
            cell.setup(viewModel: viewModel)
            return cell
        case .note(let viewModel):
            let cell: NoteInputCell = configure(tableView.dequeueReusableCell(for:), for: indexPath)
            cell.setup(viewModel: viewModel)
            return cell
        case .image(let viewModel):
            let cell: ImageCell = configure(tableView.dequeueReusableCell(for:), for: indexPath)
            cell.setup(viewModel: viewModel)
            return cell
        case let .activityIndicator(viewModel, viewSpec):
            let cell: ActivityIndicatorCell = configure(tableView.dequeueReusableCell(for:), for: indexPath)
            cell.setup(viewModel: viewModel, viewSpec: viewSpec)
            return cell
        }
    }

    public func bind(to components: Property<[FormComponent]>, configurator: FormCellConfigurator?) {
        guard let tableView = self.tableView else { return }
        self.configurator = configurator

        tableView.register(TextInputCell.self)
        tableView.register(TitledTextInputCell.self)
        tableView.register(PhoneInputCell.self)
        tableView.register(EmptySpaceCell.self)
        tableView.register(DescriptionCell.self)
        tableView.register(ActionCell.self)
        tableView.register(ActionInputCell.self)
        tableView.register(ActionDescriptionCell.self)
        tableView.register(FacebookCell.self)
        tableView.register(ToggleCell.self)
        tableView.register(SegmentedCell.self)
        tableView.register(SelectionCell.self)
        tableView.register(NoteInputCell.self)
        tableView.register(TextOptionsCell.self)
        tableView.register(ImageOptionsCell.self)
        tableView.register(ImageCell.self)
        tableView.register(ActivityIndicatorCell.self)

        tableView.dataSource = self

        // Reset the table view internal state.
        tableView.reloadData()

        components.producer
            .combinePrevious([])
            .take(duringLifetimeOf: tableView)
            .observe(on: UIScheduler())
            .startWithValues { previous, current in
                guard let tableView = self.tableView else { return }
                self.components = current

                // Dismiss any first responder to avoid view corruption.
                tableView.endEditing(true)

                tableView.beginUpdates()

                for step in Dwifft.diff(previous, current) {
                    switch step {
                    case let .insert(index, _):
                        tableView.insertRows(at: [IndexPath(row: index, section: 0)], with: .fade)

                    case let .delete(index, _):
                        tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .fade)
                    }
                }

                tableView.endUpdates()
                self.configurator?.updateSeparatorsOfVisibleCells()
            }
    }
}
