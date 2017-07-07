import UIKit
import ReactiveSwift
import ReactiveCocoa
import enum Result.NoError

open class FormViewController: UIViewController {

    private let form: Form
    private let visualDependencies: VisualDependenciesProtocol

    public let tableView: UITableView

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
        let dataSource = FormTableViewDataSource.bind(tableView, to: form.components)

        if let focusableForm = form as? FocusableForm {
            let focusedComponent = focusableForm.focusableController.focusedComponent.signal
                .skipNil()
                .skipRepeats()

            NotificationCenter.default.reactive.keyboardChange
                .skipRepeats { lhs, rhs in lhs.endFrame == rhs.endFrame }
                .combineLatest(with: focusedComponent)
                .take(duringLifetimeOf: self)
                .observe(on: UIScheduler())
                .observeValues { [weak tableView, dataSource] context, component in
                    guard let tableView = tableView else { return }

                    // TODO: [David] Use block-based animations
                    UIView.beginAnimations(nil, context: nil)
                    UIView.setAnimationDuration(context.animationDuration)
//                    UIView.setAnimationCurve(context.animationCurve) // NOTE: This currently crashes, needs to be fixed in ReactiveCocoa

                    let bottomInset = tableView.frame.height - context.endFrame.minY

                    tableView.contentInset.bottom = bottomInset
                    tableView.scrollIndicatorInsets.bottom = bottomInset

                    if let index = dataSource.components.index(of: component) {
                        tableView.scrollToRow(at: IndexPath(row: index, section: 0), at: .none, animated: true)
                    }

                    UIView.commitAnimations()
                }

            reactive.signal(for: #selector(viewDidAppear(_:)))
                .take(during: reactive.lifetime)
                .take(first: 1)
                .observeValues { _ in focusableForm.focusableController.setupAutoFocus() }
        }
    }

    @available(*, unavailable)
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func loadView() {
        view = tableView
    }

    open override func viewDidLoad() {
        super.viewDidLoad()

        tableView.keyboardDismissMode = .onDrag

        visualDependencies.styles.backgroundFormColor
            .apply(to: tableView)

        if let navigationBar = navigationController?.navigationBar {
            visualDependencies.styles.navigationBarBackButton
                .apply(view: navigationBar, to: navigationItem)
        }
    }

    public func enableFormAutoFocus() {
        if let focusableForm = form as? FocusableForm {
            reactive.signal(for: #selector(viewDidAppear(_:)))
                .take(during: reactive.lifetime)
                .take(first: 1)
                .observeValues { _ in focusableForm.enableAutoFocus() }
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
}
