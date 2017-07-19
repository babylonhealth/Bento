import UIKit
import ReactiveSwift
import ReactiveCocoa

public final class SegmentedCell: FormCell {
    let stackView: UIStackView

    var viewModel: SegmentedCellViewModel!

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        stackView = SegmentedCell.makeStackView()

        super.init(style: style, reuseIdentifier: reuseIdentifier)

        // Disable the default selection style.
        selectionStyle = .none

        // Disable autoresizing.
        translatesAutoresizingMaskIntoConstraints = false

        // Honor the FormView layout margins.
        preservesSuperviewLayoutMargins = true
        contentView.preservesSuperviewLayoutMargins = true

        // Install the stack view.
        SegmentedCell.install(stackView, in: contentView)
    }

    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup(viewModel: SegmentedCellViewModel) {
        self.viewModel = viewModel

        for view in stackView.arrangedSubviews {
            view.removeFromSuperview()
        }

        let isEnabled = viewModel.isEnabled.and(isFormEnabled).producer
            .take(until: reactive.prepareForReuse)

        func bindButton(_ position: Int, _ button: SegmentedCellButton) -> CollectionOfOne<UIView> {
            viewModel.visualDependencies.styles.segmentedCellButton.apply(to: button)
            button.disabledColor = viewModel.visualDependencies.styles.appColors.disabledColor

            let option = viewModel.options[position]
            button.setTitle(option.title, for: .normal)

            let icon = option.icon.withRenderingMode(.alwaysTemplate)
            button.setImage(icon, for: .normal)

            button.reactive.isSelected <~ viewModel.selection.map { $0 == position }.producer
                .take(until: reactive.prepareForReuse)

            viewModel.selection <~ button.reactive.controlEvents(.primaryActionTriggered)
                .take(until: reactive.prepareForReuse)
                .map { _ in position }

            button.reactive.isEnabled <~ isEnabled

            return CollectionOfOne(button)
        }

        let buttons = generateButtons(count: viewModel.options.count)

        let constraints = buttons
            .dropFirst()
            .map { $0.widthAnchor.constraint(equalTo: buttons[0].widthAnchor) }

        buttons
            .enumerated()
            .map(bindButton)
            .joined(separator: generateSeparator())
            .forEach(stackView.addArrangedSubview)

        NSLayoutConstraint.activate(constraints)
    }

    private func generateButtons(count: Int) -> [SegmentedCellButton] {
        return (0 ..< count).map { _ in
            let button = SegmentedCellButton()
            button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 4)
            button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 0)
            return button
        }
    }

    private func generateSeparator() -> CollectionOfOne<UIView> {
        let separator = UIView()
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.widthAnchor.constraint(equalToConstant: 1.0).isActive = true
        separator.backgroundColor = viewModel.visualDependencies.styles.appColors.formSeparatorColor
        return CollectionOfOne(separator)
    }

    private static func makeStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.distribution = .fillProportionally
        return stackView
    }

    private static func install(_ stackView: UIStackView, in contentView: UIView) {
        contentView.addSubview(stackView)

        // Constrain the stack view to the content view.
        let requiredConstraint = [
            stackView.leftAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leftAnchor),
            stackView.rightAnchor.constraint(equalTo: contentView.layoutMarginsGuide.rightAnchor),
            stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 44.0)
        ]

        let lowerPriorityConstraints = [
            stackView.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor),
            stackView.bottomAnchor.constraint(greaterThanOrEqualTo: contentView.bottomAnchor)
        ]

        lowerPriorityConstraints.forEach { $0.priority = UILayoutPriorityDefaultLow }

        NSLayoutConstraint.activate(requiredConstraint)
        NSLayoutConstraint.activate(lowerPriorityConstraints)
    }
}

extension SegmentedCell: ReusableCell {}

private class SegmentedCellButton: UIButton {
    var disabledColor: UIColor?  {
        didSet {
            setTitleColor(disabledColor, for: .normal)
        }
    }

    override var isSelected: Bool {
        didSet {
            tintColor = isSelected ? nil : disabledColor
        }
    }

    init() {
        super.init(frame: .zero)
        setTitleColor(disabledColor, for: .normal)
        setTitleColor(tintColor, for: .selected)
        imageView?.tintColor = nil
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    override func tintColorDidChange() {
        super.tintColorDidChange()
        setTitleColor(tintColor, for: .selected)
    }
}
