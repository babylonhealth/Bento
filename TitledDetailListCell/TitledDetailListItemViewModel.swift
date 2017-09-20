struct TitledDetailListItemViewModel{
    let visualDependencies: VisualDependenciesProtocol
    let item: TitledDetailListItem

    func applyTitleStyle(to label: UILabel) {
        visualDependencies.styles.labelTextFootnote.apply(to: label)
        label.textColor = Colors.black
        label.text = item.title
    }

    func applyDescriptionStyle(to label: UILabel) {
        visualDependencies.styles.labelTextFootnote.apply(to: label)
        label.textColor = Colors.silverGrey
        label.text = item.description
    }
}
