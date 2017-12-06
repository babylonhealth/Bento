import Foundation
import UIKit
import ReactiveSwift
import ReactiveCocoa
import enum Result.NoError

public final class SelectionCellViewModel {
    public let title: String
    public let subtitle: String?
    public let icon: SignalProducer<UIImage, NoError>?
    public let identifier: Int

    public init(title: String, subtitle: String? = nil, icon: SignalProducer<UIImage, NoError>? = nil, identifier: Int) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.identifier = identifier
    }
}
