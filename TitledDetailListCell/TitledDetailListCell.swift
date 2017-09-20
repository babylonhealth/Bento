extension TitledDetailListCell: NibLoadableCell {}

final class TitledDetailListCell: FormCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var listStackView: UIStackView!

    private var viewModel: TitledDetailListCellViewModel!

    func setup(viewModel: TitledDetailListCellViewModel) {
        viewModel.applyTitleStyle(to: titleLabel)

        let subviews = listStackView.subviews
        subviews.forEach { $0.removeFromSuperview() }

        viewModel.items.forEach { item in
            let view = viewFromNib(classType: TitledDetailListItemView.self) as! TitledDetailListItemView
            view.setup(viewModel: item)
            listStackView.addArrangedSubview(view)
        }
    }
}
