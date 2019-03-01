import Foundation
import UIKit
import Bento
import BentoKit
import StyleSheets

protocol Navigator: class {
    func showAlert(title: String, message: String)
}

final class SignUpViewController: UIViewController, SignUpPresenterDelegate, Navigator {
    @IBOutlet weak var tableView: UITableView!
    private let presenter: SignUpPresenter
    private let renderer: SignUpRenderer
    private lazy var adapter: BoxTableViewAdapter<SignUpRenderer.SectionID, SignUpRenderer.RowID> = {
        return BoxTableViewAdapter(with: tableView)
    }()

    required init?(coder aDecoder: NSCoder) {
        presenter = SignUpPresenter()
        renderer = SignUpRenderer(presenter: presenter)
        super.init(coder: aDecoder)
        presenter.delegate = self
        presenter.navigator = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "SignUp"
        tableView.prepareForBoxRendering(with: adapter)
        tableView.tableFooterView = UIView()
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

extension String: BentoKit.Option {
    public var displayName: String { return self }
}
