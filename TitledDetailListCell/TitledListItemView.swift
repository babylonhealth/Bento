class TitledListItemView: UIView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    func setup(viewModel: TitledListItemViewModel) {
        viewModel.applyTitleStyle(to: titleLabel)
        viewModel.applyDescriptionStyle(to: descriptionLabel)
    }
}
