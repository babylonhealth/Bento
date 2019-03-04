import Bento
import BentoKit
import StyleSheets
import UIKit

final class CenterYLayoutExampleViewController: UIViewController {
    @IBOutlet var collectionView: UICollectionView!
    private let layout = CenterYCollectionViewLayout<Int, Int>()
    private var state = 0 {
        didSet {
            render()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        render()
    }

    @IBAction func increment() {
        state += 1
    }

    @IBAction func decrement() {
        if state == 0 {
            return
        }
        state -= 1
    }

    private func setup() {
        collectionView.render(Box<Int, Int>.empty)
        collectionView.setCollectionViewLayout(layout, animated: false)
    }

    private func render() {
        let box = Box<Int, Int>.empty
            |-+ Section(id: 0)
            |---* (0...state).map {
                Node(
                    id: $0,
                    component: Component.Description(
                        text: "Row \($0)",
                        styleSheet: Component.Description.StyleSheet()
                            .compose(\.backgroundColor, .white)
                    )
                )
            }
        layout.box = box
        collectionView.render(box)
    }
}
