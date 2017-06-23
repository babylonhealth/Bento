import ReactiveSwift
import Result
import TTTAttributedLabel

public struct ActionDescriptionCellViewModel {
    let visualDependencies: VisualDependenciesProtocol
    let title: NSAttributedString
    let action: Action<Void, Void, NoError>

    public init(visualDependencies: VisualDependenciesProtocol, title: NSAttributedString, action: Action<Void, Void, NoError>) {
        self.visualDependencies = visualDependencies
        self.title = title
        self.action = action
    }

    func applyTitleStyle(to label: TTTAttributedLabel) {
        visualDependencies.styles.attributedLabelFormFooter.apply(to: label)
    }

    func applyBackgroundColor(to views: [UIView]) {
        self.visualDependencies.styles.backgroundTransparentColor.apply(to: views)
    }

    func setupTitle(to label: TTTAttributedLabel) {
        label.setText(title)
    }
}
