import UIKit
import ReactiveSwift
import ReactiveCocoa

public final class SegmentedCell: FormCell {

    let stackView: UIStackView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.isLayoutMarginsRelativeArrangement = true
        $0.distribution = .fillProportionally
        return $0
    }(UIStackView())

    var viewModel: SegmentedCellViewModel!

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none

        translatesAutoresizingMaskIntoConstraints = false
        preservesSuperviewLayoutMargins = true
        contentView.preservesSuperviewLayoutMargins = true
        contentView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leftAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leftAnchor),
            stackView.rightAnchor.constraint(equalTo: contentView.layoutMarginsGuide.rightAnchor),
            stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 44.0)
        ])

        let lowerPriorityConstraints = [
            stackView.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor),
            stackView.bottomAnchor.constraint(greaterThanOrEqualTo: contentView.bottomAnchor)
        ]

        lowerPriorityConstraints.forEach { $0.priority = UILayoutPriorityDefaultLow }
        NSLayoutConstraint.activate(lowerPriorityConstraints)
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

        var first: UIButton?

        generateButtons()
            .map { [$0] }
            .joined(separator: [generateSeparator()])
            .forEach { view in
                stackView.addArrangedSubview(view)

                if let button = view as? UIButton {
                    if let first = first {
                        button.widthAnchor.constraint(equalTo: first.widthAnchor).isActive = true
                    } else {
                        first = button
                    }
                }
            }
    }

    private func generateButtons() -> [UIButton] {
        let isEnabled = viewModel.isEnabled.and(isFormEnabled).producer
            .take(until: reactive.prepareForReuse)

        return viewModel.options.enumerated().map { index, option in
            let button = SegmentedCellButton(disabledColor: viewModel.visualDependencies.styles.appColors.disabledColor)
            viewModel.visualDependencies.styles.segmentedCellButton.apply(to: button)
            button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 4)
            button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 0)
            button.setTitle(option.title, for: .normal)

            let icon = option.icon.withRenderingMode(.alwaysTemplate)
            button.setImage(icon, for: .normal)

            button.reactive.isSelected <~ viewModel.selection.map { $0 == index }.producer
                .take(until: reactive.prepareForReuse)

            button.reactive.controlEvents(.primaryActionTriggered)
                .take(until: reactive.prepareForReuse)
                .observeValues { [selection = viewModel.selection] _ in
                    selection.value = index
                }

            button.reactive.isEnabled <~ isEnabled
            return button
        }
    }

    private func generateSeparator() -> UIView {
        let separator = UIView()
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.widthAnchor.constraint(equalToConstant: 1.0).isActive = true
        separator.backgroundColor = viewModel.visualDependencies.styles.appColors.disabledColor
        return separator
    }
}

extension SegmentedCell: ReusableCell {}

private class SegmentedCellButton: UIButton {
    private let disabledColor: UIColor

    override var isSelected: Bool {
        get { return super.isSelected }
        set {
            super.isSelected = newValue
            imageView?.tintColor = newValue ? tintColor : disabledColor
        }
    }

    init(disabledColor: UIColor) {
        self.disabledColor = disabledColor
        super.init(frame: .zero)
        setTitleColor(disabledColor, for: .normal)
        setTitleColor(tintColor, for: .selected)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    override func tintColorDidChange() {
        super.tintColorDidChange()
        setTitleColor(tintColor, for: .selected)
    }
}
