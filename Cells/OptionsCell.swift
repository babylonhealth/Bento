import ReactiveSwift
import ReactiveCocoa
import UIKit
import BabylonFoundation

final class TextOptionsCell: OptionsCell {
    fileprivate var viewModel: TextOptionsCellViewModel!
    fileprivate var viewSpec: TextOptionsCellViewSpec!

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        collectionView.register(TextOptionsCollectionCell.self)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.allowsSelection = true
        collectionView.allowsMultipleSelection = false
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup(viewModel: TextOptionsCellViewModel, viewSpec: TextOptionsCellViewSpec) {
        self.viewModel = viewModel
        self.viewSpec = viewSpec

        collectionViewHeightConstraint.constant = viewSpec.collectionHeight
        collectionViewHeightConstraint.isActive = true
        heightConstraint.constant = viewSpec.cellHeight
        heightConstraint.isActive = true
    }
}

extension TextOptionsCell: ReusableCell, UICollectionViewDelegateFlowLayout {}

extension TextOptionsCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = self.viewModel.items.value[indexPath.row]
        let cell: TextOptionsCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: TextOptionsCollectionCell.reuseIdentifier, for: indexPath) as! TextOptionsCollectionCell
        viewSpec.buttonStyle.apply(to: cell.slotButton)
        cell.slotButton.setTitle(item, for: .normal)
        cell.slotButton.titleLabel?.font = viewSpec.buttonFont
        cell.slotButton.isSelected = cell.isSelected
        let buttonSize = size(from: item, font: viewSpec.buttonFont, offset: viewSpec.buttonOffset)
        cell.slotButtonWidthConstraint.constant = buttonSize.width
        cell.slotButton.isUserInteractionEnabled = false
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let item = self.viewModel.items.value[indexPath.row]
        var itemSize = size(from: item, font: viewSpec.buttonFont, offset: viewSpec.buttonOffset)
        return CGSize(width: itemSize.width, height: viewSpec.collectionHeight)
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.items.value.count
    }
}

extension TextOptionsCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.selectionAction.apply().start()
    }
}

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
    }
}

extension ImageOptionsCell: ReusableCell, UICollectionViewDelegateFlowLayout {}

extension ImageOptionsCell: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = self.viewModel.items.value[indexPath.row]
        let cell: ImageOptionsCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageOptionsCollectionCell.reuseIdentifier, for: indexPath) as! ImageOptionsCollectionCell
        cell.mediaImageView.image = item
        cell.closeButton.setImage(viewSpec.mediaCellCloseIcon, for: .normal)
        cell.closeButton.reactive.pressed = CocoaAction(viewModel.destructiveAction)
        return cell
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel.items.value.count
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: viewSpec.mediaCellDimension, height: viewSpec.mediaCellDimension)
    }
}

extension ImageOptionsCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //TODO: Trigger selectionAction here
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
        self.collectionViewHeightConstraint = collectionView.heightAnchor.constraint(equalToConstant: 0)
    }
    required init(coder aDecoder: NSCoder) { fatalError("init(coder:)") }
}

private extension CGSize {
    func offsetBy(dx: CGFloat, dy: CGFloat) -> CGSize {
        return CGSize(width: self.width+dx, height: self.height+dy)
    }
}

fileprivate func size(from string: String, font: UIFont, offset: CGSize) -> CGSize {
    return NSString(string: string).size(attributes: [NSFontAttributeName : font]).offsetBy(dx: offset.width, dy: offset.height)
}