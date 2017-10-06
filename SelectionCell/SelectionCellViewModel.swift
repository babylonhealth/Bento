import Foundation
import UIKit
import ReactiveSwift
import ReactiveCocoa
import enum Result.NoError

public final class SelectionCellViewModel {
    public let title: String
    public let icon: SignalProducer<UIImage, NoError>?
    public let identifier: Int

    public init(title: String, icon: SignalProducer<UIImage, NoError>? = nil, identifier: Int) {
        (self.title, self.icon, self.identifier) = (title, icon, identifier)
    }
}
