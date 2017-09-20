class TitledDetailListItemView: UIView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    func setup(viewModel: TitledDetailListItemViewModel) {
        viewModel.applyTitleStyle(to: titleLabel)
        viewModel.applyDescriptionStyle(to: descriptionLabel)
    }
}
