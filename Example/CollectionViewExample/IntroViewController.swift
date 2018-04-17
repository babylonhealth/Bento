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
    let viewModel = IntroViewModel()

    @IBOutlet weak var finishButtonVisibleConstraint: NSLayoutConstraint!
    @IBOutlet weak var finishButtonNotVisibleConstraint: NSLayoutConstraint!

    //MARK: UIViewController lifecycle
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.setupPageControl()
    }
}

extension IntroViewController: UICollectionViewDelegateFlowLayout {
    // MARK: UICollectionViewDelegateFlowLayout

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size;
    }
}

extension IntroViewController: UICollectionViewDataSource {
    // MARK: UICollectionViewDataSource

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel.content.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cellViewModel = IntroCellViewModel(content: self.viewModel.content[indexPath.row])

        return defaultCellBuilder.makeCell(viewModel: cellViewModel,
                                           collectionView: collectionView,
                                           indexPath: indexPath)
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

extension IntroViewController {
    //MARK: Setup Components design
    fileprivate func setupPageControl() {
        self.pageControl.numberOfPages = self.viewModel.content.count
        self.pageControl.pageIndicatorTintColor = UIColor.lightGray
    }
}
