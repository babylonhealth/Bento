import UIKit
import ReactiveSwift
import ReactiveCocoa
import enum Result.NoError

open class FormViewController: UIViewController {

    private let form: Form
    private let visualDependencies: VisualDependenciesProtocol

    private lazy var formView: FormView = FormView(form: self.form)

    // TODO: 🔥 [David] Once again generics, you need to find a better way
    public var tableView: UITableView {
        return formView.tableView
    }

    public var tableDataSource: FormTableViewDataSource {
        return formView.tableDataSource
    }

public init<F: Form>(form: F, visualDependencies: VisualDependenciesProtocol) {
        self.form = form
        self.visualDependencies = visualDependencies

        super.init(nibName: nil, bundle: nil)

        if let focusableForm = form as? FocusableForm {

            let focusedComponent = focusableForm.focusableController.focusedComponent.signal
                .skipNil()
                .skipRepeats()

            NotificationCenter.default.reactive.keyboardChange
                .skipRepeats { lhs, rhs in lhs.endFrame == rhs.endFrame }
                .combineLatest(with: focusedComponent)
                .observe(on: UIScheduler())
                .observeValues { context, component in

                    // TODO: [David] Use block-based animations
                    UIView.beginAnimations(nil, context: nil)
                    UIView.setAnimationDuration(context.animationDuration)
//                    UIView.setAnimationCurve(context.animationCurve) // NOTE: This currently crashes, needs to be fixed in ReactiveCocoa

                    let bottomInset = self.formView.frame.height - context.endFrame.minY

                    self.formView.tableView.contentInset.bottom = bottomInset
                    self.formView.tableView.scrollIndicatorInsets.bottom = bottomInset

                    if let index = self.formView.tableDataSource.components.index(of: component) {
                        self.tableView.scrollToRow(at: IndexPath(row: index, section: 0), at: .none, animated: true)
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
        view = formView
    }

    open override func viewDidLoad() {
        super.viewDidLoad()

        tableView.keyboardDismissMode = .onDrag

        visualDependencies.styles.backgroundFormColor
            .apply(to: view)

        visualDependencies.styles.backgroundTransparentColor
            .apply(to: formView.tableView)

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

private class FormView: UIView {

    let tableView: UITableView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.separatorStyle = .none
        return $0
    }(UITableView())

    let tableDataSource: FormTableViewDataSource
    let tableDelegate: FormTableViewDelegate

    init(form: Form) {
        tableDataSource = FormTableViewDataSource(tableView: tableView, components: form.components.value)
        tableDelegate = FormTableViewDelegate()

        super.init(frame: .zero)

        tableView.dataSource = tableDataSource
        tableView.delegate = tableDelegate

        addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.leftAnchor.constraint(equalTo: leftAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
            tableView.rightAnchor.constraint(equalTo: rightAnchor),
            ])
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
