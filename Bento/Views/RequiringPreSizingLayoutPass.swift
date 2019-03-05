/// Declare that the view requires an extra layout pass before Auto Layout item sizing happens, so that height
/// calculation for components containing free-form UI elements, e.g. text labels, would be correct.
///
/// For example, it can be used in conjuction with `UILabel.preferredMaxLayoutWidth` to ensure a vertical stack of
/// multi-line labels in a self-sizing item would have sufficient height to reveal all texts:
///
/// ```
/// // A stack view which is a direct child of `self`.
/// let stackView: UIStackView
///
/// // A bunch of labels which are arranged by `stackView`.
/// let labels: [UILabel]
///
/// override func layoutSubviews() {
///     super.layoutSubviews()
///
///     labels.forEach { $0.preferredMaxLayoutWidth = stackView.bounds.width }
/// }
/// ```
///
/// The pre-sizing layout pass would not produce the correct height for the root view, but it would produce correct
/// horizontal positions, invoke `layoutSubviews()` and set `preferredMaxLayoutWidth` to the expected width. So when
/// item sizing happens afterwards, Auto Layout would use the expected width to compute the height for free-form UI
/// elements, and generate the correct height.
///
/// - important: The mechanism is always enabled for Bento-enabled `UITableView`, both vanilla and size-caching. For
///              `UICollectionView` however, it is available only for size-caching `UICollectionView`, since
///              `UICollectionView` can be flexibly laid out and thus Bento does not have sufficient knowledge when
///              working with vanilla `UICollectionView`.
public protocol PreSizingLayoutPassRequiring {}

extension UIView {
    private var needsPresizingLayoutPass: Bool {
        return self is PreSizingLayoutPassRequiring
            || subviews.contains(where: { $0.needsPresizingLayoutPass })
    }

    func triggerPresizingLayoutPassIfNeeded(forTargetSize size: CGSize) {
        if needsPresizingLayoutPass {
            bounds.size = size
            layoutIfNeeded()
        }
    }
}
