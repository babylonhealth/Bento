import UIKit
import ReactiveSwift
import Result

open class ActivityIndicatorCell: FormCell {
    let activityIndicator: UIActivityIndicatorView

    override public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        activityIndicator = UIActivityIndicatorView()
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        preservesSuperviewLayoutMargins = true
        contentView.preservesSuperviewLayoutMargins = true
        contentView.addSubview(activityIndicator)

        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.activityIndicatorViewStyle = .gray

        NSLayoutConstraint.activate([
            activityIndicator.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            activityIndicator.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
        ])
    }

    public required init?(coder: NSCoder) {
        fatalError()
    }

    func setup(viewModel: ActivityIndicatorCellViewModel, viewSpec: ActivityIndicatorCellViewSpec) {
        viewSpec.cellStyle?.apply(to: self)

        activityIndicator.reactive.isAnimating <~ viewModel.isRefreshing.producer
            .take(until: reactive.prepareForReuse)
    }
}

extension ActivityIndicatorCell: ReusableCell {}
