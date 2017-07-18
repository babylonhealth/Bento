import UIKit
import ReactiveSwift
import ReactiveCocoa

public final class SegmentedCell: FormCell {

    let stackView: UIStackView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.isLayoutMarginsRelativeArrangement = true
        $0.distribution = .fillProportionally
        $0.layoutMargins = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        return $0
    }(UIStackView())

    var viewModel: SegmentedCellViewModel!

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none

        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leftAnchor.constraint(equalTo: leftAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.rightAnchor.constraint(equalTo: rightAnchor),
        ])
    }

    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup(viewModel: SegmentedCellViewModel) {
        self.viewModel = viewModel

        stackView.arrangedSubviews
            .forEach(stackView.removeArrangedSubview)

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
            let button = SegmentedCellButton()

            viewModel.visualDependencies.styles.segmentedCellButton.apply(to: button)
            button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 4)
            button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 0)
            button.setTitle(option.title, for: .normal)
            button.setImage(UIImage(named: option.imageName), for: .normal)
            button.setImage(UIImage(named: option.imageName)?.withRenderingMode(.alwaysTemplate), for: .selected)
            button.reactive.isSelected <~ viewModel.selectedIndex.map { $0 == index }
            button.reactive.pressed = CocoaAction(viewModel.selection, input: index)
            button.reactive.isEnabled <~ isEnabled
            return button
        }
    }

    private func generateSeparator() -> UIView {
        let separator = UIView()
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.widthAnchor.constraint(equalToConstant: 1.0).isActive = true
        separator.backgroundColor = Colors.hintGrey
        return separator
    }
}

extension SegmentedCell: ReusableCell {}

private class SegmentedCellButton: UIButton {
    init() {
        super.init(frame: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override var isSelected: Bool {
        get { return super.isSelected }
        set {
            super.isSelected = newValue
            imageView?.tintColor = titleColor(for: newValue ? .selected : .normal)
        }
    }
}
