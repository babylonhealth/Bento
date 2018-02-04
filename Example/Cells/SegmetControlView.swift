import UIKit
import FormsKit

final class SegmetControlView: UIView {
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    var onSegmentSelected: ((Int) -> Void)?
    
    @IBAction private func segmentedControlSelected() {
        onSegmentSelected?(segmentedControl.selectedSegmentIndex)
    }
}

final class SegmetControlComponent: Renderable {
    private let firstIcon: UIImage
    private let secondIcon: UIImage
    private let onSegmentSelected: (Int) -> Void
    
    init(firstIcon: UIImage, secondIcon: UIImage, onSegmentSelected: @escaping (Int) -> Void) {
        self.firstIcon = firstIcon
        self.secondIcon = secondIcon
        self.onSegmentSelected = onSegmentSelected
    }
    
    func render(in view: SegmetControlView) {
        view.segmentedControl.setImage(firstIcon, forSegmentAt: 0)
        view.segmentedControl.setImage(secondIcon, forSegmentAt: 1)
        view.onSegmentSelected = onSegmentSelected
    }
}
