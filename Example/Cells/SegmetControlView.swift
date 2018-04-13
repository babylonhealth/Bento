import UIKit
import Bento

final class SegmetControlView: UIView, NibLoadable {
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    var onSegmentSelected: ((Int) -> Void)?
    
    @IBAction private func segmentedControlSelected() {
        onSegmentSelected?(segmentedControl.selectedSegmentIndex)
    }
}

final class SegmetControlComponent: Renderable {
    private let firstIcon: UIImage
    private let secondIcon: UIImage
    private let selectedIndex: Int
    private let onSegmentSelected: (Int) -> Void
    
    init(firstIcon: UIImage, secondIcon: UIImage, selectedIndex: Int = 0, onSegmentSelected: @escaping (Int) -> Void) {
        self.firstIcon = firstIcon
        self.secondIcon = secondIcon
        self.selectedIndex = selectedIndex
        self.onSegmentSelected = onSegmentSelected
    }
    
    func render(in view: SegmetControlView) {
        view.segmentedControl.setImage(firstIcon, forSegmentAt: 0)
        view.segmentedControl.setImage(secondIcon, forSegmentAt: 1)
        view.segmentedControl.selectedSegmentIndex = selectedIndex
        view.onSegmentSelected = onSegmentSelected
    }
}
