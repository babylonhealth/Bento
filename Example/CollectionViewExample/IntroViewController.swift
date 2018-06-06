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
            IntroContent(image: UIImage(named: "bentobox-hero")!,
                         title: "Bento Box Hero",
                         body: "with Teriyaki Pineapple and Speckled Rice"),
            IntroContent(image: UIImage(named: "jackfruit-stir-fry-hero")!,
                         title: "Jackfruit Shiitake Stir-fry",
                         body: "with Quinoa and Spinach"),
            IntroContent(image: UIImage(named: "peanut-tofu-hero")!,
                         title: "Crispy Peanut Tofu",
                         body: "with Zucchini and Carrot Noodles"),
            IntroContent(image: UIImage(named: "sushi-ritto-hero")!,
                         title: "Sushi-rito",
                         body: "with Roma Edamame Salad and Wasabi Aioli")
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
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        itemSize = CGSize(width: UIScreen.main.bounds.size.width,
                          height: UIScreen.main.bounds.size.height / 4)
        minimumInteritemSpacing = 0
        minimumLineSpacing = 0
    }
}
