import UIKit
import Bento
import Kingfisher

final class MovieComponent: Renderable, Deletable {
    private let movie: Movie
    private let didDelete: (() -> Void)?

    init(movie: Movie, didDelete: (() -> Void)? = nil) {
        self.movie = movie
        self.didDelete = didDelete
    }

    func render(in view: MovieComponentView) {
        view.title.text = movie.title
        view.imageView.kf
            .setImage(with: movie.posterURL,
                      options: [KingfisherOptionsInfoItem.transition(ImageTransition.fade(0.2))])
    }

    var canBeDeleted: Bool {
        return didDelete != nil
    }

    var deleteActionText: String {
        return "Remove"
    }

    func delete() {
        didDelete?()
    }
}

final class MovieComponentView: UIView, NibLoadable {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var imageView: UIImageView!
}
