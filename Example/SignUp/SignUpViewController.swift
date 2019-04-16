import Foundation
import UIKit
import Bento
import BentoKit


protocol Navigator: class {
    func showAlert(title: String, message: String)
}

final class SignUpViewController: UIViewController, SignUpView, Navigator {
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.keyboardDismissMode = .interactive
            tableView.prepareForBoxRendering(with: adapter)
            tableView.tableFooterView = UIView()
        }
    }
    private let presenter: SignUpPresenter
    private let renderer: SignUpRenderer
    private lazy var adapter: BoxTableViewAdapter<SignUpRenderer.SectionID, SignUpRenderer.RowID> = {
        return BoxTableViewAdapter(with: tableView)
    }()

    required init?(coder aDecoder: NSCoder) {
        presenter = SignUpPresenter()
        renderer = SignUpRenderer(presenter: presenter)
        super.init(coder: aDecoder)
        presenter.view = self
        presenter.navigator = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "SignUp"
        let gray = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
        let backgroundColor = gray
        tableView.backgroundColor = backgroundColor
        view.backgroundColor = backgroundColor
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.layoutMargins = .zero
        presenter.viewDidAppear()
    }

    func showAlert(title: String, message: String) {
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "Ok", style: .destructive))
        self.present(alertView, animated: true)
    }

    func render(_ state: SignUpPresenter.State) {
        let box = renderer.createBox(from: state)
        tableView.render(box)
    }
}

extension String: Bento.Option {
    public var displayName: String { return self }
}
