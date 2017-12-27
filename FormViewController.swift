import UIKit
import BabylonFoundation
import ReactiveSwift
import ReactiveCocoa
import enum Result.NoError

open class FormViewController<F: Form>: UIViewController, UITableViewDelegate {
    public let tableView: FormTableView
    public let form: F
    fileprivate let dataSource: FormTableViewDataSource<F.Identifier>

    fileprivate let viewSpec: FormViewSpec
    private var keyboardChangeDisposable: Disposable?

    private var viewConstraints: [NSLayoutConstraint] = []

    public var focus: BindingTarget<()> {
        return self.reactive.makeBindingTarget { base, _ in
            base.focus()
        }
    }

    public init(form: F, viewSpec: FormViewSpec) {
        self.form = form
        self.viewSpec = viewSpec
        tableView = FormTableView()
        dataSource = FormTableViewDataSource(for: tableView, separatorVisibility: viewSpec.separatorVisibility)
        super.init(nibName: nil, bundle: nil)

        setupTableView()

        if let refreshable = form as? Refreshable {
            setupRefreshControl(with: refreshable.refresh)
        }
    }

    @available(*, unavailable)
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupTableView() {
        automaticallyAdjustsScrollViewInsets = false

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        tableView.delegate = self

        dataSource.bind(to: form.tree, configurator: self)
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
                    // Treat the keyboard as hidden if the table view has been removed
                    // from a `UIWindow`.
                    let keyboardHeight = tableView.window.map { $0.frame.height - context.endFrame.minY } ?? 0
                    tableView.keyboardHeight = keyboardHeight
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

        view.addSubview(tableView)
        tableView.keyboardDismissMode = .interactive

        tableView.backgroundColor = .clear
        viewSpec.style?.apply(to: view)

        activateViewConstraints([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    public func activateViewConstraints(_ constraints: [NSLayoutConstraint]) {
        if !viewConstraints.isEmpty {
            NSLayoutConstraint.deactivate(viewConstraints)
        }

        self.viewConstraints = constraints

        if !constraints.isEmpty {
            NSLayoutConstraint.activate(constraints)
        }
    }

    private func setupRefreshControl(with action: ActionInput<Void>) {
        let refreshControl = UIRefreshControl()
        tableView.refreshControl = refreshControl
        refreshControl.reactive.isEnabled <~ action.isEnabled.producer.observe(on: UIScheduler())
        refreshControl.reactive.isRefreshing <~ action.isExecuting.producer.observe(on: UIScheduler())
        action <~ refreshControl.reactive.controlEvents(.valueChanged).filterMap { $0.isRefreshing ? () : nil }
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
        cell.visibility = dataSource.separatorVisibility(forCellAt: indexPath.row)
    }

    // [Michael] this method is used for iOS < 11.0
    // Once we require iOS 11 this method can be removed
    public func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        guard let deletable = tableView.cellForRow(at: indexPath) as? UITableViewCell & DeletableCell,
              deletable.canBeDeleted,
              form.isSubmitting.value.isFalse else {
            return []
        }

        let deleteAction = UITableViewRowAction(style: .destructive, title: deletable.deleteActionText) { [weak deletable, weak dataSource] _, indexPath in
            guard let dataSource = dataSource,
                  let deletable = deletable
                else { return }

            let delete = deletable.delete()
            dataSource.deleteRowForSwipeAction(at: indexPath) {
                delete.start()
            }
        }

        return [deleteAction]
    }

    @available(iOS 11.0, *)
    public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let deletable = tableView.cellForRow(at: indexPath) as? UITableViewCell & DeletableCell,
              deletable.canBeDeleted,
              form.isSubmitting.value.isFalse else {
            return UISwipeActionsConfiguration(actions: [])
        }

        let deleteAction = UIContextualAction(
            style: .destructive,
            title: deletable.deleteActionText,
            handler: { [weak tableView, weak dataSource, weak deletable] (action, view, handler) in
                guard let dataSource = dataSource,
                    let deletable = deletable,
                    let indexPath = tableView?.indexPath(for: deletable) else {
                        handler(false)
                        return
                }

                let delete = deletable.delete()
                dataSource.deleteRowForSwipeAction(at: indexPath, contextCompletion: handler) {
                    delete.start()
                }
            }
        )
        deleteAction.backgroundColor = .red

        return UISwipeActionsConfiguration(actions: [deleteAction])
    }

    @available(iOS 11, *)
    open override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        updatePreferredContentHeight()
    }

    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updatePreferredContentHeight()

        guard #available(iOS 11.0, *) else {
            tableView.additionalContentInsets = UIEdgeInsets(top: topLayoutGuide.length,
                                                             left: 0,
                                                             bottom: bottomLayoutGuide.length,
                                                             right: 0)
            return
        }
    }

    private func updatePreferredContentHeight() {
        if #available(iOS 11, *) {
            tableView.preferredContentHeight = view.safeAreaLayoutGuide.layoutFrame.height
        } else {
            tableView.preferredContentHeight = view.frame.height - topLayoutGuide.length - bottomLayoutGuide.length
        }
    }
}

extension FormViewController: FormCellConfigurator {
    public func configure(_ cell: FormCell) {
        cell.configure(form.isSubmitting.negate(), viewSpec.separatorColor)
        viewSpec.style?.apply(to: cell)
        (cell as? FocusableCell)?.delegate = self
        (cell as? DynamicHeightCell)?.heightDelegate = self

        if let itemCell = cell as? FormItemCell {
            viewSpec.itemCellStyle?.apply(to: itemCell)
        }
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

                unsafeDowncast(cell, to: FormCell.self)
                    .visibility = dataSource.separatorVisibility(forCellAt: indexPath.row)
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
