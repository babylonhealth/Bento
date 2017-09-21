extension TitledListCell: NibLoadableCell {}

final class TitledListCell: FormCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var listStackView: UIStackView!

    private var viewModel: TitledListCellViewModel!

    func setup(viewModel: TitledListCellViewModel) {
        viewModel.applyTitleStyle(to: titleLabel)

        let subviews = listStackView.subviews
        subviews.forEach { $0.removeFromSuperview() }

        viewModel.items.forEach { item in
            let view = viewFromNib(classType: TitledListItemView.self) as! TitledListItemView
            view.setup(viewModel: item)
            listStackView.addArrangedSubview(view)
        }
    }
}
