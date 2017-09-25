class TitledListItemView: UIView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    func setup(viewModel: TitledListItemViewModel, viewSpec: TitledListItemViewSpec) {
        viewSpec.titleStyle.apply(to: titleLabel)
        viewSpec.descriptionStyle.apply(to: descriptionLabel)
        titleLabel.textColor = viewSpec.titleColor
        descriptionLabel.textColor = viewSpec.descriptionColor
        titleLabel.text = viewModel.title
        descriptionLabel.text = viewModel.description
    }
}
