import ReactiveSwift
import ReactiveCocoa
import UIKit
import BabylonFoundation

final class ImageOptionsCell: FormItemCell {
    let collectionView: UICollectionView
    var collectionViewHeightConstraint: NSLayoutConstraint!

    fileprivate var viewModel: ImageOptionsCellViewModel!
    fileprivate var viewSpec: ImageOptionsCellViewSpec!

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        self.collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)

        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(collectionView)

        setupCollectionView()
    }

    @available(*, unavailable)
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup(viewModel: ImageOptionsCellViewModel, viewSpec: ImageOptionsCellViewSpec) {
        self.viewModel = viewModel
        self.viewSpec = viewSpec

        collectionViewHeightConstraint.constant = viewSpec.mediaCellDimension
        collectionView.reloadData()
    }

    private func setupCollectionView() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        collectionViewHeightConstraint = collectionView.heightAnchor.constraint(equalToConstant: 0)
        collectionViewHeightConstraint.priority = UILayoutPriority(UILayoutPriority.required.rawValue - 1)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            collectionViewHeightConstraint
        ])

        collectionView.preservesSuperviewLayoutMargins = true
        collectionView.isScrollEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.bounces = true
        collectionView.alwaysBounceHorizontal = true
        collectionView.backgroundColor = .clear

        collectionView.register(ImageOptionsCollectionCell.self)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
}

extension ImageOptionsCell: ReusableCell, UICollectionViewDelegateFlowLayout {}

extension ImageOptionsCell: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = self.viewModel.items[indexPath.row]
        let cell: ImageOptionsCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageOptionsCollectionCell.reuseIdentifier, for: indexPath) as! ImageOptionsCollectionCell
        cell.mediaImageView.image = item

        if let destructive = viewModel.destructiveAction {
            cell.closeButton.isHidden = false
            cell.closeButton.setImage(viewSpec.mediaCellCloseIcon, for: .normal)
            cell.closeButton.reactive.pressed = CocoaAction(destructive, input: indexPath.row)
        } else {
            cell.closeButton.isHidden = true
        }

        return cell
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel.items.count
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: viewSpec.mediaCellDimension, height: viewSpec.mediaCellDimension)
    }
}

extension ImageOptionsCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.selectionAction.apply(indexPath.row).start()
    }
}
