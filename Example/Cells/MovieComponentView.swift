import UIKit
import Bento
import Kingfisher

final class MovieComponent: Renderable {
    private let movie: Movie

    init(movie: Movie) {
        self.movie = movie
    }

    func render(in view: MovieComponentView) {
        view.title.text = movie.title
        view.imageView.kf
            .setImage(with: movie.posterURL,
                      options: [KingfisherOptionsInfoItem.transition(ImageTransition.fade(0.2))])
    }
}

final class MovieComponentView: UIView, NibLoadable {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var imageView: UIImageView!
}
