import AVFoundation
import AVKit
import ReactiveCocoa
import ReactiveSwift
import Result
import UIKit

public final class FoodListViewController: UIViewController {
    @IBOutlet var collectionView: UICollectionView!

    private lazy var viewModel = FoodListViewModel(content:
        [
            FoodItem(image: UIImage(named: "coffee")!,
                         title: "Coffee",
                         body: "A brewed drink prepared from roasted coffee beans, which are the seeds of berries from the Coffea plant."),
            FoodItem(image: UIImage(named: "pomegranate")!,
                         title: "Pomegranate",
                         body: "A fruit-bearing deciduous shrub or small tree in the family Lythraceae."),
            FoodItem(image: UIImage(named: "strawberries")!,
                         title: "Strawberry",
                         body: "The garden strawberry is a widely grown hybrid species of the genus Fragaria, collectively known as the strawberries."),
            FoodItem(image: UIImage(named: "cherries")!,
                         title: "Cherry",
                         body: "Is the fruit of many plants of the genus Prunus, and is a fleshy drupe (stone fruit).")
    ])
    private let renderer = FoodListRenderer()
    private var (lifetime, token) = Lifetime.make()

    @IBOutlet var finishButtonVisibleConstraint: NSLayoutConstraint!
    @IBOutlet var finishButtonNotVisibleConstraint: NSLayoutConstraint!

    // MARK: UIViewController lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.state
            .map { [renderer] in
                renderer.render(state: $0)
            }
            .take(during: lifetime)
            .startWithValues { [collectionView] in
                collectionView?.render($0)
            }
    }

    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        (lifetime, token) = Lifetime.make()
    }

    private func setupCollectionView() {
        let adapter = CustomCollectionViewAdapter<FoodListRenderer.SectionId, FoodListRenderer.RowId>(with: collectionView)
        collectionView.prepareForBoxRendering(with: adapter)
        collectionView.collectionViewLayout = IntroCollectionViewLayout()
    }
}

final class IntroCollectionViewLayout: UICollectionViewFlowLayout {
    override init() {
        super.init()
        itemSize = CGSize(width: UIScreen.main.bounds.size.width,
                          height: UIScreen.main.bounds.size.height / 4)
        minimumInteritemSpacing = 4
        minimumLineSpacing = 4
        headerReferenceSize = CGSize(width: 1, height: 100)
        footerReferenceSize = CGSize(width: 1, height: 1)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        itemSize = CGSize(width: UIScreen.main.bounds.size.width,
                          height: UIScreen.main.bounds.size.height / 4)
        minimumInteritemSpacing = 0
        minimumLineSpacing = 0
    }
}
