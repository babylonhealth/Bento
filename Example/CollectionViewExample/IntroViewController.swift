import UIKit
import ReactiveCocoa
import ReactiveSwift
import Result
import AVKit
import AVFoundation

public final class IntroViewController: UIViewController {

    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var primaryButton: UIButton!
    @IBOutlet weak var secondaryButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var mainViewFooterContainer: UIView!

    fileprivate var defaultCellBuilder = IntroDefaultBuilder()

    let content = [
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
    ]

    lazy var viewModel = IntroViewModel(IntroRenderer(content))

    @IBOutlet weak var finishButtonVisibleConstraint: NSLayoutConstraint!
    @IBOutlet weak var finishButtonNotVisibleConstraint: NSLayoutConstraint!

    //MARK: UIViewController lifecycle
    override public func viewDidLoad() {
        super.viewDidLoad()
        //self.setupPageControl()

        viewModel.box
            .producer
            .startWithValues(collectionView.render)
    }
}

extension IntroViewController: UICollectionViewDelegateFlowLayout {
    // MARK: UICollectionViewDelegateFlowLayout

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size;
    }
}

extension IntroViewController: UIScrollViewDelegate {
    // MARK: UIScrollView Delegate

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //setting the pageControl currentPage
        let center = CGPoint(x: scrollView.contentOffset.x + (scrollView.frame.width / 2),
                             y: (scrollView.frame.height / 2))
        if let ip = self.collectionView.indexPathForItem(at: center) {
            self.pageControl.currentPage = ip.row
        }
    }
}

