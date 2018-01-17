import ReactiveSwift
import ReactiveCocoa
import UIKit
import BabylonFoundation

final class TextOptionsCell: FormItemCell, ReusableCell {
    fileprivate var viewModel: TextOptionsCellViewModel!
    fileprivate var viewSpec: TextOptionsCellViewSpec!
    fileprivate let callToActionLabel = UILabel()

    let scrollView: UIScrollView
    let stackView: UIStackView
    let labelScrollViewSpacingConstraint: NSLayoutConstraint

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        (stackView, scrollView) = TextOptionsCell.createScrollableStackView()
        labelScrollViewSpacingConstraint = callToActionLabel.bottomAnchor
            .constraint(equalTo: scrollView.topAnchor, constant: 0)

        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none

        preservesSuperviewLayoutMargins = true
        contentView.preservesSuperviewLayoutMargins = true

        callToActionLabel.translatesAutoresizingMaskIntoConstraints = false
        callToActionLabel.numberOfLines = 0

        contentView.addSubview(callToActionLabel)
        contentView.addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
            callToActionLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            callToActionLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            callToActionLabel.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            labelScrollViewSpacingConstraint
        ])
    }

    @available(*, unavailable)
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup(viewModel: TextOptionsCellViewModel, viewSpec: TextOptionsCellViewSpec) {
        self.viewModel = viewModel
        self.viewSpec = viewSpec

        callToActionLabel.text = viewModel.headline
        viewSpec.labelStyle.apply(to: callToActionLabel)
        labelScrollViewSpacingConstraint.constant = callToActionLabel.text != nil ? -viewSpec.collectionTopMargin : 0

        stackView.arrangedSubviews
            .forEach { $0.removeFromSuperview() }

        viewModel.items.value
            .enumerated()
            .map(createButton)
            .forEach(stackView.addArrangedSubview)
    }

    private func createButton(at index: Int, for item: String) -> UIButton {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        viewSpec.buttonStyle.apply(to: button)
        button.contentEdgeInsets = viewSpec.buttonInsets
        button.setTitle(item, for: .normal)

        button.reactive.controlEvents(.primaryActionTriggered)
            .observeValues { [weak self] _ in
                self?.didSelectOption(at: index)
            }

        return button
    }

    private func didSelectOption(at position: Int) {
        viewModel.selectionAction.apply(position).start()
    }

    override func layoutMarginsDidChange() {
        super.layoutMarginsDidChange()

        scrollView.contentInset = UIEdgeInsets(top: 0,
                                               left: contentView.layoutMargins.left,
                                               bottom: 0,
                                               right: contentView.layoutMargins.right)
    }

    private static func createScrollableStackView() -> (stackView: UIStackView, scrollView: UIScrollView) {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.bounces = true
        scrollView.alwaysBounceHorizontal = true
        scrollView.alwaysBounceVertical = false

        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.spacing = 10

        scrollView.addSubview(stackView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: stackView.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: stackView.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            scrollView.heightAnchor.constraint(equalTo: stackView.heightAnchor)
        ])
        
        return (stackView, scrollView)
    }
}
