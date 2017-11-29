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
import FlexibleDiff

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
    func update(_ style: FormStyle)
}

public final class FormTableViewDataSource<Identifier: Hashable>: NSObject, UITableViewDataSource {
    private var items: [FormItem<Identifier>]

    private weak var tableView: UITableView?
    private weak var configurator: FormCellConfigurator?
    private let separatorVisibility: FormViewSpec.SeparatorVisibility

    public var indexOfPreferredRowForInitialFocus: Int? {
        if let startIndex = items.index(where: { $0.component.viewModel is FocusableFormComponent }) {
            let slice = items[startIndex ..< items.endIndex]
            guard let preferred = slice.index(where: { ($0.component.viewModel as? FocusableFormComponent)?.isPreferredForFocusing ?? false }) else {
                return startIndex
            }
            return preferred
        }
        return nil
    }

    public init(for tableView: UITableView, separatorVisibility: FormViewSpec.SeparatorVisibility) {
        self.items = []
        self.tableView = tableView
        self.separatorVisibility = separatorVisibility
        super.init()
    }

    /// Compute the separator visibility for the specified cell.
    ///
    /// - parameters:
    ///   - row: The cell index.
    ///
    /// - returns: The separator visibility for the specified cell.
    public func separatorVisibility(forCellAt row: Int) -> FormCellSeparatorVisibility {
        let definesSection = items[row].component.definesSection
        let nextCellDefinesSection = row < items.count - 1 ? items[row + 1].component.definesSection : true

        switch separatorVisibility {
        case .betweenItemsAndSections:
            switch (definesSection, nextCellDefinesSection) {
            case (false, false):
                return .visible
            case (true, false), (false, true):
                return .visibleNoInset
            case (true, true):
                return .invisible
            }
        case .betweenItems:
            return !definesSection && !nextCellDefinesSection ? .visible : .invisible
        case .none:
            return .invisible
        }
    }

    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    private func configureCell<Cell: FormCell & ReusableCell>(at indexPath: IndexPath, strategy: GetCellStrategy, in tableView: UITableView, with id: Identifier?) throws -> Cell {
        let cell: Cell

        switch strategy {
        case .dequeueCell:
            cell = tableView.dequeueReusableCell(withIdentifier: Cell.reuseIdentifier, for: indexPath) as! Cell
        case .visibleCell:
            guard let visibleCell = tableView.cellForRow(at: indexPath)
                else { throw GetCellError.cellInvisible }

            // TODO: Remove this workaround once `FormBuilder(V1)` is obsolete.
            //
            // fatalError("The component identifier \"\(id)\" is being used with more than one component types.")
            guard visibleCell is Cell else { throw GetCellError.typeMismatch }

            cell = visibleCell as! Cell
            cell.prepareForReuse()
        }

        configurator?.configure(cell)

        #if DEBUG
        cell.accessibilityIdentifier = id.map(String.init(describing:)) ?? "_space"
        #endif

        return cell
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return try! updateRow(at: indexPath, strategy: .dequeueCell, in: tableView, with: items[indexPath.row])
    }

    @discardableResult
    private func updateRow(at indexPath: IndexPath, strategy: GetCellStrategy, in tableView: UITableView, with item: FormItem<Identifier>) throws -> UITableViewCell {
        switch item.component {
        case .textInput(let viewModel):
            let cell: TextInputCell = try configureCell(at: indexPath, strategy: strategy, in: tableView, with: item.id)
            cell.setup(viewModel: viewModel)
            return cell
        case .titledTextInput(let viewModel):
            let cell: TitledTextInputCell = try configureCell(at: indexPath, strategy: strategy, in: tableView, with: item.id)
            cell.setup(viewModel: viewModel)
            return cell
        case .phoneTextInput(let viewModel):
            let cell: PhoneInputCell = try configureCell(at: indexPath, strategy: strategy, in: tableView, with: item.id)
            cell.setup(viewModel: viewModel)
            return cell
        case .space(let viewModel):
            let cell: EmptySpaceCell = try configureCell(at: indexPath, strategy: strategy, in: tableView, with: item.id)
            cell.setup(viewModel: viewModel)
            return cell
        case .description(let viewModel):
            let cell: DescriptionCell = try configureCell(at: indexPath, strategy: strategy, in: tableView, with: item.id)
            cell.setup(viewModel: viewModel)
            return cell
        case .actionButton(let viewModel, let spec):
            let cell: ActionCell = try configureCell(at: indexPath, strategy: strategy, in: tableView, with: item.id)
            cell.setup(viewModel: viewModel, spec: spec)
            return cell
        case .actionInput(let viewModel):
            let cell: ActionInputCell = try configureCell(at: indexPath, strategy: strategy, in: tableView, with: item.id)
            cell.setup(viewModel: viewModel)
            return cell
        case .actionDescription(let viewModel):
            let cell: ActionDescriptionCell = try configureCell(at: indexPath, strategy: strategy, in: tableView, with: item.id)
            cell.setup(viewModel: viewModel)
            return cell
        case .toggle(let viewModel):
            let cell: ToggleCell = try configureCell(at: indexPath, strategy: strategy, in: tableView, with: item.id)
            cell.setup(viewModel: viewModel)
            return cell
        case .segmentedInput(let viewModel):
            let cell: SegmentedCell = try configureCell(at: indexPath, strategy: strategy, in: tableView, with: item.id)
            cell.setup(viewModel: viewModel)
            return cell
        case let .textOptionsInput(viewModel, viewSpec):
            let cell: TextOptionsCell = try configureCell(at: indexPath, strategy: strategy, in: tableView, with: item.id)
            cell.setup(viewModel: viewModel, viewSpec: viewSpec)
            return cell
        case let .imageOptionsInput(viewModel, viewSpec):
            let cell: ImageOptionsCell = try configureCell(at: indexPath, strategy: strategy, in: tableView, with: item.id)
            cell.setup(viewModel: viewModel, viewSpec: viewSpec)
            return cell
        case let .selection(selectionItem, group, spec):
            let cell: SelectionCell = try configureCell(at: indexPath, strategy: strategy, in: tableView, with: item.id)
            cell.configure(for: selectionItem, in: group, spec: spec)
            return cell
        case .noteInput(let viewModel):
            let cell: NoteInputCell = try configureCell(at: indexPath, strategy: strategy, in: tableView, with: item.id)
            cell.setup(viewModel: viewModel)
            return cell
        case .note(let viewModel):
            let cell: NoteInputCell = try configureCell(at: indexPath, strategy: strategy, in: tableView, with: item.id)
            cell.setup(viewModel: viewModel)
            return cell
        case .image(let viewModel):
            let cell: ImageCell = try configureCell(at: indexPath, strategy: strategy, in: tableView, with: item.id)
            cell.setup(viewModel: viewModel)
            return cell
        case let .activityIndicator(viewModel, viewSpec):
            let cell: ActivityIndicatorCell = try configureCell(at: indexPath, strategy: strategy, in: tableView, with: item.id)
            cell.setup(viewModel: viewModel, viewSpec: viewSpec)
            return cell
        case let .titledList(viewModel, viewSpec):
            let cell: TitledListCell = try configureCell(at: indexPath, strategy: strategy, in: tableView, with: item.id)
            cell.setup(viewModel: viewModel, viewSpec: viewSpec)
            return cell
        }
    }

    public func bind(to components: Property<FormTree<Identifier>>, configurator: FormCellConfigurator?) {
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
        tableView.register(ToggleCell.self)
        tableView.register(SegmentedCell.self)
        tableView.register(SelectionCell.self)
        tableView.register(NoteInputCell.self)
        tableView.register(TextOptionsCell.self)
        tableView.register(ImageOptionsCell.self)
        tableView.register(ImageCell.self)
        tableView.register(ActivityIndicatorCell.self)
        tableView.register(TitledListCell.self)

        tableView.dataSource = self

        // Reset the table view internal state.
        tableView.reloadData()

        components.producer
            .combinePrevious(FormTree(items: []))
            .take(duringLifetimeOf: tableView)
            .observe(on: UIScheduler())
            .startWithValues { previous, current in
                guard let tableView = self.tableView else { return }

                // Dismiss any first responder to avoid view corruption.
                tableView.endEditing(true)

                // Update the cached items.
                self.items = current.items

                let changeset = Changeset(previous: previous.items,
                                          current: current.items,
                                          identifier: DiffIdentifier.init,
                                          areEqual: { $0.component == $1.component })

                var indexPathsForWorkaround = [IndexPath]()

                tableView.beginUpdates()

                // `fade` still looks the best.
                tableView.deleteRows(at: changeset.removals.map { [0, $0] }, with: .fade)
                tableView.insertRows(at: changeset.inserts.map { [0, $0] }, with: .fade)

                for move in changeset.moves {
                    tableView.moveRow(at: [0, move.source], to: [0, move.destination])
                }

                // NOTE: [anders] `reloadRows` clashes with `moveRow`. Since we
                //       do not need to reanimate these cells out & in, they
                //       are rebound with the new cell VM manually here.
                //
                //       It is important to update the cells as part of the
                //       UITableView animation transaction, since the reloading
                //       might affect the cell content height.
                [changeset.moves.lazy
                    .flatMap { $0.isMutated ? ($0.source, $0.destination) : nil },
                 changeset.mutations.lazy.map { ($0, $0) }]
                    .joined()
                    .forEach { source, destination in
                        do {
                            try self.updateRow(at: [0, source], strategy: .visibleCell, in: tableView, with: current.items[destination])
                        } catch GetCellError.typeMismatch {
                            indexPathsForWorkaround.append([0, destination])
                        } catch _ {}
                    }

                tableView.endUpdates()

                self.configurator?.updateSeparatorsOfVisibleCells()
                self.configurator?.update(current.style)

                // TODO: Remove this workaround once `FormBuilder(V1)` is
                //       obsolete.
                if indexPathsForWorkaround.count > 0 {
                    tableView.reloadRows(at: indexPathsForWorkaround, with: .none)
                }
            }
    }

    private struct DiffIdentifier: Hashable {
        private let id: Identifier?

        var hashValue: Int {
            return id?.hashValue ?? 0
        }

        init(_ item: FormItem<Identifier>) {
            self.id = item.id
        }

        static func == (left: DiffIdentifier, right: DiffIdentifier) -> Bool {
            return left.id == right.id
        }
    }
}

private enum GetCellError: Error {
    case typeMismatch
    case cellInvisible
}

private enum GetCellStrategy {
    case visibleCell
    case dequeueCell
}
