import UIKit
import Bento

final class LoadingIndicatorView: UIView, NibLoadable{
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
}

final class LoadingIndicatorComponent: Renderable {
    private let isLoading: Bool

    init(isLoading: Bool) {
        self.isLoading = isLoading
    }

    func render(in view: LoadingIndicatorView) {
        view.activityIndicator.hidesWhenStopped = true
        (isLoading ? view.activityIndicator.startAnimating : view.activityIndicator.stopAnimating)()
    }
}

