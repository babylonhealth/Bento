import UIKit
import ReactiveSwift
import ReactiveCocoa
import enum Result.NoError

open class FormViewController: UIViewController {
    public let tableView: UITableView

    fileprivate let form: Form
    fileprivate var dataSource: FormTableViewDataSource!

    private let visualDependencies: VisualDependenciesProtocol
    private var keyboardChangeDisposable: Disposable?

    public init<F: Form>(form: F, visualDependencies: VisualDependenciesProtocol) {
        self.form = form
        self.visualDependencies = visualDependencies

        tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44

        super.init(nibName: nil, bundle: nil)

        tableView.delegate = self
        dataSource = FormTableViewDataSource.bind(tableView, to: form.components, configurator: self)
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
        var indexOfPreferredRow: Int? {
            if let startIndex = dataSource.components.index(where: { $0.viewModel is FocusableFormComponent }) {
                let slice = dataSource.components[startIndex ..< dataSource.components.endIndex]
                guard let preferred = slice.index(where: { ($0.viewModel as? FocusableFormComponent)?.isPreferredForFocusing ?? false }) else {
                    return startIndex
                }
                return preferred
            }
            return nil
        }

        if let row = indexOfPreferredRow {
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
    public func configure<Cell : UITableViewCell>(_ cell: Cell) {
        (cell as? FormCell)?.configure(form.submiting.negate())
        (cell as? FocusableCell)?.delegate = self
    }
}

extension FormViewController: FocusableCellDelegate {
    public func focusableCellHasSuccessor(_ cell: FocusableCell) -> Bool {
        return nextFocusableCell(after: cell) != nil
    }

    public func focusableCellShouldYieldFocus(_ cell: FocusableCell) -> Bool {
        guard let next = nextFocusableCell(after: cell) else {
            return false
        }

        next.focus()
        return true
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

extension FormViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // NOTE: [David] This cannot removed otherwise we are going to introduce a side-effect in `ActionInputCell`
        // which is triggering the relevant action when the cell is selected. We don't want that selection both visually
        // as in terms of logic since when the cell is being reused it will receive a call for `setSelected(_:animated:)`
        // with a true value which will wrongly lead to invocation of the action.
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
