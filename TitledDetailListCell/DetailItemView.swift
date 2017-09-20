class DetailItemView: UIView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    func setup(viewModel: DetailItemViewModel) {
        viewModel.applyTitleStyle(to: titleLabel)
        viewModel.applyDescriptionStyle(to: descriptionLabel)
    }
}
