import UIKit

public protocol IntroViewModelProtocol {
    
    var content: IntroContent { get }
    func setupTitle(with label: UILabel)
    func setupBody(with label: UILabel)
}

struct IntroCellViewModel: IntroViewModelProtocol {

    let content: IntroContent

    func setupTitle(with label: UILabel) {
        label.text = self.content.title
    }

    func setupBody(with label: UILabel) {
        label.text = self.content.body
    }
}
