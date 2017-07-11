import Foundation
import UIKit

public final class SelectionCellViewModel {
    public let title: String
    public let icon: UIImage?
    public let identifier: Int

    public init(title: String, icon: UIImage?, identifier: Int) {
        (self.title, self.icon, self.identifier) = (title, icon, identifier)
    }
}
