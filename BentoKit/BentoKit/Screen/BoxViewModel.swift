import Foundation
import ReactiveSwift

public protocol BoxViewModel: AnyObject {
    associatedtype State
    associatedtype Action

    var state: Property<State>  { get }

    func send(action: Action)
}
