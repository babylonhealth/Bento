import AVFoundation
import AVKit
import ReactiveCocoa
import ReactiveSwift
import Result
import UIKit

public final class IntroViewController: UIViewController {
    @IBOutlet var pageControl: UIPageControl!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var primaryButton: UIButton!
    @IBOutlet var secondaryButton: UIButton!
    @IBOutlet var closeButton: UIButton!
    @IBOutlet var mainViewFooterContainer: UIView!

    private lazy var viewModel = IntroViewModel(content:
        [
            IntroContent(image: UIImage(named: "coffee")!,
                         title: "Coffee",
                         body: "A brewed drink prepared from roasted coffee beans, which are the seeds of berries from the Coffea plant."),
            IntroContent(image: UIImage(named: "pomegranate")!,
                         title: "Pomegranate",
                         body: "A fruit-bearing deciduous shrub or small tree in the family Lythraceae."),
            IntroContent(image: UIImage(named: "strawberries")!,
                         title: "Strawberry",
                         body: "The garden strawberry is a widely grown hybrid species of the genus Fragaria, collectively known as the strawberries."),
            IntroContent(image: UIImage(named: "cherries")!,
                         title: "Cherry",
                         body: "Is the fruit of many plants of the genus Prunus, and is a fleshy drupe (stone fruit).")
    ])
    private let renderer = IntroRenderer()
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
