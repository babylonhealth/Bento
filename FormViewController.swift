import UIKit
import ReactiveSwift
import ReactiveCocoa
import enum Result.NoError

open class FormViewController: UIViewController {
    public let tableView: UITableView

    fileprivate let form: Form
    fileprivate let dataSource: FormTableViewDataSource

    fileprivate let visualDependencies: VisualDependenciesProtocol
    private var keyboardChangeDisposable: Disposable?

    public init<F: Form>(form: F, visualDependencies: VisualDependenciesProtocol) {
        self.form = form
        self.visualDependencies = visualDependencies

        tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44

        dataSource = FormTableViewDataSource(for: tableView)

        super.init(nibName: nil, bundle: nil)
        tableView.delegate = self

        dataSource.bind(to: form.components, configurator: self)
    }

    @available(*, unavailable)
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func loadView() {
        view = tableView
    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        keyboardChangeDisposable = NotificationCenter.default.reactive
            .keyboardChange
            .skipRepeats { lhs, rhs in lhs.endFrame == rhs.endFrame }
            .take(duringLifetimeOf: self)
            .observe(on: UIScheduler())
            .observeValues { [weak tableView] context in
                guard let tableView = tableView else { return }

                func animate() {
                    let keyboardHeight = (tableView.window!.frame.height - context.endFrame.minY)
                    tableView.contentInset.bottom = keyboardHeight
                    tableView.scrollIndicatorInsets.bottom = keyboardHeight
                }

                UIView.animate(withDuration: context.animationDuration,
                               delay: 0.0,
                               options: UIViewAnimationOptions(context.animationCurve),
                               animations: animate,
                               completion: nil)
            }
    }

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tableView.endEditing(true)
    }

    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        keyboardChangeDisposable?.dispose()
    }

    open override func viewDidLoad() {
        super.viewDidLoad()

        tableView.keyboardDismissMode = .interactive

        visualDependencies.styles.backgroundFormColor
            .apply(to: tableView)

        if let navigationBar = navigationController?.navigationBar {
            visualDependencies.styles.navigationBarBackButton
                .apply(view: navigationBar, to: navigationItem)
        }
    }

    /// Focus the preferred focusable row in the form.
    ///
    /// If there are multiple preferred focusable row, the first preferred focusable row
    /// would be picked. If there is no preferred focusable row, the first focusable row
    /// would be picked. If there is no focusable row at all, no action would be
    /// performed.
    ///
    /// - warning: `focus(animated:)` should not be called in `viewWillAppear(_:)`.
    public func focus(animated: Bool = true) {
        if let row = dataSource.indexOfPreferredRowForInitialFocus {
            CATransaction.begin()

            tableView.scrollToRow(at: IndexPath(row: row, section: 0), at: .top, animated: animated)
            CATransaction.setCompletionBlock { [weak tableView] in
                if let cell = tableView?.cellForRow(at: IndexPath(row: row, section: 0)),
                   let focusableCell = cell as? FocusableCell {
                    focusableCell.focus()
                }
            }

            CATransaction.commit()
        }
    }
}

extension FormViewController: FormCellConfigurator {
    public func configure<Cell : FormCell>(_ cell: Cell) {
        cell.configure(form.submiting.negate(), visualDependencies.styles.appColors.formSeparatorColor)
        (cell as? FocusableCell)?.delegate = self
        (cell as? DynamicHeightCell)?.heightDelegate = self
    }

    public func updateSeparatorsOfVisibleCells() {
        // This method complements `willDisplayCell`, which is not called on untouched
        // rows during a form layout update. Since the adjacent cells of these untouched
        // rows may require a change in separator visibility, we perform a pass on all
        // visible cells.

        if let indexPaths = tableView.indexPathsForVisibleRows {
            for indexPath in indexPaths {
                guard let cell = tableView.cellForRow(at: indexPath) else {
                    continue
                }

                let formCell = unsafeDowncast(cell, to: FormCell.self)
                formCell.separator.isHidden = dataSource.hasAdjacentSectionDefiningCells(at: indexPath.row)
            }
        }
    }
}

extension FormViewController: FocusableCellDelegate {
    public func focusableCellHasSuccessor(_ cell: FocusableCell) -> Bool {
        return nextFocusableCell(after: cell) != nil
    }

    public func focusableCellWillResignFirstResponder(_ cell: FocusableCell) -> Bool {
        guard let next = nextFocusableCell(after: cell) else {
            // The cell should proceed on resigning its (subview's) first responder status.
            return true
        }

        // The first responder status would be taken over by the next focusable cell, so
        // the cell should not attempt to resign.
        next.focus()
        return false
    }

    private func nextFocusableCell(after cell: FocusableCell) -> FocusableCell? {
        let cell = cell as! UITableViewCell

        guard let indexPath = tableView.indexPath(for: cell) else {
            return nil
        }

        for row in indexPath.row + 1 ..< tableView.numberOfRows(inSection: 0) {
            let indexPath = IndexPath(row: row, section: 0)

            if let nextCell = tableView.cellForRow(at: indexPath) as? FocusableCell {
                return nextCell
            }
        }

        return nil
    }
}

extension FormViewController: DynamicHeightCellDelegate {
    public func dynamicHeightCellHeightDidChange(delta: CGFloat) {
        UIView.setAnimationsEnabled(false)
        tableView.beginUpdates()
        tableView.endUpdates()
        UIView.setAnimationsEnabled(true)

        if delta > 0.0 {
            var contentOffset = tableView.contentOffset
            contentOffset.y += delta
            tableView.setContentOffset(contentOffset, animated: false)
        }
    }
}

extension FormViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // NOTE: [David] This cannot removed otherwise we are going to introduce a side-effect in `ActionInputCell`
        // which is triggering the relevant action when the cell is selected. We don't want that selection both visually
        // as in terms of logic since when the cell is being reused it will receive a call for `setSelected(_:animated:)`
        // with a true value which will wrongly lead to invocation of the action.
        tableView.deselectRow(at: indexPath, animated: true)
    }

    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // See `updateSeparatorsOfVisibleCells()` for the implementation note.
        let cell = unsafeDowncast(cell, to: FormCell.self)
        cell.separator.isHidden = dataSource.hasAdjacentSectionDefiningCells(at: indexPath.row)
    }
}
