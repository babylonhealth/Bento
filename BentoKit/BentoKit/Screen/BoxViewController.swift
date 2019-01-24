import Bento
import ReactiveCocoa
import ReactiveSwift
import Result
import UIKit

open class BoxViewController<ViewModel: BoxViewModel, Renderer: BoxRenderer, Appearance>
: UIViewController where ViewModel.State == Renderer.State, ViewModel.Action == Renderer.Action, Renderer.Appearance == Appearance {
    public let viewModel: ViewModel
    private let rendererConfig: Renderer.Config
    private let appearance: Property<Appearance>
    private let (traits, traitObserver) = Signal<UITraitCollection, NoError>.pipe()
    public let tableView: BentoTableView

    private let topTableView: BentoTableView
    private lazy var topTableViewHeight = topTableView.heightAnchor
        .constraint(equalToConstant: 0)
        .activated()

    private let bottomTableView: BentoTableView
    private lazy var bottomTableViewHeight = bottomTableView.heightAnchor
        .constraint(equalToConstant: 0)
        .activated()

    private var topBox: Box<Renderer.SectionID, Renderer.ItemID> = .empty
    private var bottomBox: Box<Renderer.SectionID, Renderer.ItemID> = .empty

    private var keyboardChangeDisposable: Disposable?
    private let hasViewAppeared = MutableProperty(false)
    private let (focusMode, focusModeObserver) = Signal<FocusMode, NoError>.pipe()
    private var hasSetupBinding: Bool = false
    private var previousLeftBarItems: [BarButtonItem] = []
    private var previousRightBarItems: [BarButtonItem] = []

    public var additionalContentInsets: UIEdgeInsets = .zero {
        didSet {
            if #available(iOS 11, *) {
                additionalSafeAreaInsets = additionalContentInsets
            } else {
                view.setNeedsLayout()
            }
        }
    }

    public init(viewModel: ViewModel,
                renderer: Renderer.Type,
                rendererConfig: Renderer.Config,
                appearance: Property<Appearance>) {
        self.viewModel = viewModel
        self.rendererConfig = rendererConfig
        self.appearance = appearance
        self.tableView = BentoTableView(frame: .zero, style: .grouped)
        self.topTableView = BentoTableView(frame: .zero, style: .grouped)
        self.bottomTableView = BentoTableView(frame: .zero, style: .grouped)

        super.init(nibName: nil, bundle: nil)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        setupTableViews()
        setupLayout()
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // NOTE: Delay binding setup to this point as we would be sure that
        //       `traitCollection` is
        if hasSetupBinding.isFalse {
            hasSetupBinding = true

            UIView.performWithoutAnimation {
                bindViewModel()
            }
        }
    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        hasViewAppeared.value = true

        keyboardChangeDisposable = NotificationCenter.default.reactive
            .keyboard(.willChangeFrame)
            .skipRepeats { lhs, rhs in lhs.endFrame == rhs.endFrame }
            .take(duringLifetimeOf: self)
            .observe(on: UIScheduler())
            .observeValues { [weak tableView] context in
                guard let tableView = tableView else { return }

                func animate() {
                    tableView.keyboardFrame = context.endFrame

                    // We must force a layout pass so that UITableView would
                    // put the then-visible cells onto the screen before the
                    // keyboard dismissal animation begins.
                    tableView.layoutIfNeeded()

                    UIApplication.shared.sendAction(#selector(UIView.scrollToFirstResponder),
                                                    to: nil,
                                                    from: tableView,
                                                    for: nil)
                }

                UIView.animate(withDuration: context.animationDuration,
                               delay: 0.0,
                               options: UIView.AnimationOptions(context.animationCurve),
                               animations: animate,
                               completion: nil)
        }
    }

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        hasViewAppeared.value = false
    }

    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        keyboardChangeDisposable?.dispose()
    }

    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updatePreferredContentHeight()

        guard #available(iOS 11.0, *) else {
            tableView.additionalContentInsets = UIEdgeInsets(top: topLayoutGuide.length + additionalContentInsets.top,
                                                             left: additionalContentInsets.left,
                                                             bottom: bottomLayoutGuide.length + additionalContentInsets.bottom,
                                                             right: additionalContentInsets.right)
            return
        }
    }

    @available(iOS 11, *)
    open override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()

        adjustTopTableViewInset()
        adjustBottomTableViewInset()
        updatePreferredContentHeight()
    }

    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        traitObserver.send(value: traitCollection)
    }

    private func setupTableView() {
        if #available(iOS 11, *) {
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        
        if #available(iOS 11, *) {
            // For iOS 10, we use `FormTableView.additionalContentInsets`. For
            // iOS 11, `FormTableView` works well with safe area, so we would
            // simply rely on the scroll view inset adjustment mechanism.
            tableView.contentInsetAdjustmentBehavior = .always
            topTableView.contentInsetAdjustmentBehavior = .always
        }

        configureTableView(tableView)

        let adapter = BoxTableViewAdapter<Renderer.SectionID, Renderer.ItemID>(with: tableView)
        tableView.prepareForBoxRendering(with: adapter)

        focusMode
            .throttle(while: hasViewAppeared.negate(), on: UIScheduler())
            .combinePrevious(.never)
            .observeValues { [weak tableView] previous, current in
                switch (previous, current) {
                case (.never, .once):
                    tableView?.focus(animated: true)
                default:
                    break
                }
        }
    }

    private func setupTableViews() {
        setupTableView()

        func prepare(tableView: BentoTableView) {
            configureTableView(tableView).with {
                $0.separatorStyle = .none
                $0.isScrollEnabled = false
            }
            let adapter = BoxTableViewAdapter<Renderer.SectionID, Renderer.ItemID>(with: tableView)
            tableView.prepareForBoxRendering(with: adapter)
        }
        prepare(tableView: topTableView)
        prepare(tableView: bottomTableView)
    }

    @discardableResult
    private func configureTableView(_ tableView: UITableView) -> UITableView {
        return tableView.with {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.rowHeight = UITableView.automaticDimension
            $0.sectionHeaderHeight = UITableView.automaticDimension
            $0.sectionFooterHeight = UITableView.automaticDimension
            $0.estimatedRowHeight = 64
            $0.estimatedSectionHeaderHeight = 64
            $0.estimatedSectionFooterHeight = 64
            $0.keyboardDismissMode = .interactive
            $0.layoutMargins = UIEdgeInsets(top: 0, left: 16.0, bottom: 0, right: 16.0)
            $0.backgroundColor = .clear
        }
    }

    private func adjustTopTableViewInset() {
        topTableViewHeight.constant = topBox.tableViewHeightBoundTo(
            width: view.bounds.width,
            inheritedMargins: topTableView.layoutMargins.with { $0.top = 0; $0.bottom = 0 }
        )
        if #available(iOS 11, *) {
            if topTableViewHeight.constant > 0 {
                topTableView.contentInset.top = view.safeAreaInsets.top
                topTableViewHeight.constant += view.safeAreaInsets.top
            } else {
                topTableView.contentInset.top = 0
            }
        }
    }

    private func adjustBottomTableViewInset() {
        bottomTableViewHeight.constant = bottomBox.tableViewHeightBoundTo(
            width: view.bounds.width,
            inheritedMargins: bottomTableView.layoutMargins.with { $0.top = 0; $0.bottom = 0 }
        )
        if #available(iOS 11, *) {
            if bottomTableViewHeight.constant > 0 {
                bottomTableView.contentInset.bottom = view.safeAreaInsets.bottom
                bottomTableViewHeight.constant += view.safeAreaInsets.bottom
            } else {
                bottomTableView.contentInset.bottom = 0
            }
        }
    }

    func setupLayout() {
        let stackView = stack(.vertical)(
            topTableView,
            tableView,
            bottomTableView
            )
        // BHenshall: 17/10/18
        // Due to some UIKit weirdness, `navigationItem.largeTitleDisplayMode` selects the scrollView furthest back
        // in the ViewControllers view hierarchy to apply the title collapsing behaviour. As such, we need the content
        // containing tableView to be the furthest back.
        stackView.sendSubviewToBack(tableView)

        stackView.add(to: view)
            .pinEdges(to: view)
    }

    private func bindViewModel() {
        let send: (ViewModel.Action) -> Void = { [weak viewModel] in viewModel?.send(action: $0) }
        let renderer = appearance
            .combineLatest(with: Property(initial: traitCollection, then: traits))
            .map { [rendererConfig] appearance, traits -> Renderer in
                var adjustedAppearance = appearance
                adjustedAppearance.traits = traits

                return Renderer(observer: send,
                                appearance: adjustedAppearance,
                                config: rendererConfig)
        }

        SignalProducer
            .combineLatest(viewModel.state.producer, renderer.producer)
            .observe(on: UIScheduler())
            .startWithValues { [weak self] state, renderer in
                guard let `self` = self else { return }
                renderer.styleSheet.apply(to: self.view)
                renderer.pinnedToTopBoxStyleSheet.apply(to: self.topTableView)
                renderer.pinnedToBottomBoxStyleSheet.apply(to: self.bottomTableView)
                self.render(screen: renderer.render(state: state),
                            usesSystemSeparator: renderer.configuration.shouldUseSystemSeparators)
        }
    }

    private func removeAll() {
        topTableView.render(Box<Renderer.SectionID, Renderer.ItemID>.empty, animated: false)
        tableView.render(Box<Renderer.SectionID, Renderer.ItemID>.empty, animated: false)
        bottomTableView.render(Box<Renderer.SectionID, Renderer.ItemID>.empty, animated: false)
    }

    private func render(
        screen: Screen<Renderer.SectionID, Renderer.ItemID>,
        usesSystemSeparator: Bool
    ) {
        switch screen.titleItem {
        case let .text(text):
            navigationItem.title = text
        case let .view(view):
            navigationItem.titleView = view
        }

        renderBarItems(reference: \.previousLeftBarItems,
                       new: screen.leftBarItems,
                       setItems: navigationItem.setLeftBarButtonItems(_:animated:),
                       itemsKeyPath: \.leftBarButtonItems)
        renderBarItems(reference: \.previousRightBarItems,
                       new: screen.rightBarItems,
                       setItems: navigationItem.setRightBarButtonItems(_:animated:),
                       itemsKeyPath: \.rightBarButtonItems)

        let mainBox = screen.box

        self.topBox = screen.pinnedToTopBox
        self.bottomBox = screen.pinnedToBottomBox

        let shouldUseSystemSeparators = screen.shouldUseSystemSeparators
            ?? usesSystemSeparator

        tableView.separatorStyle = shouldUseSystemSeparators ? .singleLine : .none

        if UIView.areAnimationsEnabled {
            tableView.transition(to: screen.formStyle, removeAll: self.removeAll) { willReload in
                self.tableView.render(mainBox, animated: willReload.isFalse)
                self.topTableView.render(self.topBox, animated: willReload.isFalse)
                self.bottomTableView.render(self.bottomBox, animated: willReload.isFalse)
                // Trigger a second layout pass so as to let complex components
                // with ambiguous height to be sized correctly.
                self.tableView.beginUpdates()
                self.tableView.endUpdates()
            }
        } else {
            tableView.formStyle = screen.formStyle
            tableView.render(mainBox, animated: false)
            tableView.layoutIfNeeded()

            UIView.performWithoutAnimation {
                // Trigger a second layout pass so as to let complex components
                // with ambiguous height to be sized correctly.
                self.tableView.beginUpdates()
                self.tableView.endUpdates()
            }

            topTableView.render(topBox, animated: false)
            bottomTableView.render(bottomBox, animated: false)
        }

        adjustTopTableViewInset()
        topTableView.layoutIfNeeded()

        adjustBottomTableViewInset()
        bottomTableView.layoutIfNeeded()

        focusModeObserver.send(value: screen.focusMode)
    }

    private func renderBarItems(
        reference: ReferenceWritableKeyPath<BoxViewController, [BarButtonItem]>,
        new: [BarButtonItem],
        setItems: ([UIBarButtonItem], Bool) -> Void,
        itemsKeyPath: KeyPath<UINavigationItem, [UIBarButtonItem]?>
    ) {
        // Toolbar items should automatically kick the first responder, so that
        // any outstanding user interaction event is emitted before the bar
        // item's callback is triggered.
        //
        // e.g. When the first responder is a MultilineTextInput component, this
        //      forces its text to be propagated to the view model, before the
        //      view model receives the event emitted by a "Submit" toolbar
        //      button.
        let resignFirstResponder: () -> Void = { [weak self] in
            self?.topTableView.endEditing(true)
            self?.tableView.endEditing(true)
            self?.bottomTableView.endEditing(true)
        }

        let hasContentChanged = self[keyPath: reference]
            .elementsEqual(new, by: BarButtonItem.hasAppearanceChanged)
            .isFalse

        if hasContentChanged {
            setItems(
                new.map { $0.make(willTriggerAction: resignFirstResponder) },
                true
            )
        } else {
            let items = navigationItem[keyPath: itemsKeyPath] ?? []
            for (lhs, rhs) in zip(new, items) {
                lhs.applyNonAppearanceChanges(to: rhs, willTriggerAction: resignFirstResponder)
            }
        }

        self[keyPath: reference] = new
    }

    private func updatePreferredContentHeight() {
        if #available(iOS 11, *) {
            tableView.preferredContentHeight = view.safeAreaLayoutGuide.layoutFrame.height
                - bottomTableViewHeight.constant
                - topTableViewHeight.constant
        } else {
            tableView.preferredContentHeight = view.frame.height
                - topLayoutGuide.length
                - bottomLayoutGuide.length
                - bottomTableViewHeight.constant
                - topTableViewHeight.constant
        }
    }
}

private extension UIView {
    @objc(bento_scrollToFirstResponder:)
    func scrollToFirstResponder(_ tableView: UITableView) {
        let origin = convert(bounds.origin, to: tableView)
        if let indexPath = tableView.indexPathForRow(at: origin) {
            tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
    }
}
