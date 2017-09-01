import ReactiveSwift
import ReactiveCocoa
import UIKit
import BabylonFoundation

final class ImageOptionsCell: OptionsCell {
    fileprivate var viewModel: ImageOptionsCellViewModel!
    fileprivate var viewSpec: ImageOptionsCellViewSpec!

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        collectionView.register(ImageOptionsCollectionCell.self)
        collectionView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        collectionView.delegate = self
        collectionView.dataSource = self
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup(viewModel: ImageOptionsCellViewModel, viewSpec: ImageOptionsCellViewSpec) {
        self.viewModel = viewModel
        self.viewSpec = viewSpec

        heightConstraint.constant = viewSpec.mediaCellDimension
        heightConstraint.isActive = true

        collectionView.reloadData()
    }
}

extension ImageOptionsCell: ReusableCell, UICollectionViewDelegateFlowLayout {}

extension ImageOptionsCell: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = self.viewModel.items[indexPath.row]
        let cell: ImageOptionsCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageOptionsCollectionCell.reuseIdentifier, for: indexPath) as! ImageOptionsCollectionCell
        cell.mediaImageView.image = item
        cell.closeButton.setImage(viewSpec.mediaCellCloseIcon, for: .normal)
        cell.closeButton.reactive.pressed = CocoaAction(viewModel.destructiveAction, input: (indexPath.row))
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

class OptionsCell: FormCell {

    let collectionView: UICollectionView
    var heightConstraint: NSLayoutConstraint!
    var collectionViewHeightConstraint: NSLayoutConstraint!

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        self.collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)

        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(collectionView)
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.collectionView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        self.collectionView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        self.collectionView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        self.collectionView.contentInset = UIEdgeInsets.init(top: 0, left: 16, bottom: 0, right: 16)
        self.collectionView.isScrollEnabled = true
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.bounces = true
        self.collectionView.alwaysBounceHorizontal = true
        self.collectionView.backgroundColor = .white

        self.heightConstraint = heightAnchor.constraint(equalToConstant: 0)
        self.heightConstraint.priority = UILayoutPriorityRequired - 1
        self.collectionViewHeightConstraint = collectionView.heightAnchor.constraint(equalToConstant: 0)
    }
    required init(coder aDecoder: NSCoder) { fatalError("init(coder:)") }
}
