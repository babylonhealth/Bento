extension TitledListCell: NibLoadableCell {}

final class TitledListCell: FormItemCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var listStackView: UIStackView!

    override func awakeFromNib() {
        super.awakeFromNib()
        listStackView.isLayoutMarginsRelativeArrangement = true
    }

    func setup(viewModel: TitledListCellViewModel, viewSpec: TitledListCellViewSpec) {
        setupTitle(viewModel: viewModel, viewSpec: viewSpec)
        setupList(viewModel: viewModel, itemViewSpec: viewSpec.itemViewSpec)
    }

    private func setupTitle(viewModel: TitledListCellViewModel, viewSpec: TitledListCellViewSpec) {
        viewSpec.titleStyle.apply(to: titleLabel)
        titleLabel.textColor = viewSpec.titleColor
        titleLabel.text = viewModel.title
    }

    private func setupList(viewModel: TitledListCellViewModel, itemViewSpec: TitledListItemViewSpec) {
        let subviews = listStackView.subviews
        subviews.forEach { $0.removeFromSuperview() }

        viewModel.items.forEach { item in
            let view = viewFromNib(classType: TitledListItemView.self) as! TitledListItemView
            view.setup(viewModel: item, viewSpec: itemViewSpec)
            listStackView.addArrangedSubview(view)
        }
    }
}
