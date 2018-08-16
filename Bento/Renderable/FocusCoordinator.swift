/// `FocusCoordinating` provides coordination of components to yield
/// first responder status, and insights of its relative position among all
/// first responder eligible components.
public protocol FocusCoordinating {
    /// Whether the focus can be moved towards the specified direction.
    func canMove(_ direction: FocusSearchDirection) -> Bool

    /// Notify the coordinator that the component intends to yield its focus to
    /// any focusable component in the specified direction. You call this method
    /// when your component is about to resign from being the first responder.
    ///
    /// - returns: `true` if the coordinator has taken over the first responder
    ///            status. `false` if the component should proceed to resign
    ///            from being the first responder as usual.
    func move(_ direction: FocusSearchDirection) -> Bool
}

public enum FocusSearchDirection {
    /// The focus should move towards the beginning of the component tree.
    case forward

    /// The focus should move towards the end of the component tree.
    case backward
}

public struct DefaultFocusCoordinator: FocusCoordinating {
    public func canMove(_ direction: FocusSearchDirection) -> Bool {
        return false
    }

    public func move(_ direction: FocusSearchDirection) -> Bool {
        return false
    }
}

private struct FocusCoordinator<Container: BentoCollectionView>: FocusCoordinating {
    func canMove(_ direction: FocusSearchDirection) -> Bool {
        return source.indexPathOfFocusableComponent(nextTo: indexPath, direction: direction, skipsPopulatedComponents: false) != nil
    }

    func move(_ direction: FocusSearchDirection) -> Bool {
        return container.focusItem(nextTo: indexPath, direction: direction, skipsPopulatedComponents: false)
    }

    private let container: Container
    private let indexPath: IndexPath
    private let source: FocusEligibilitySource

    fileprivate init(container: Container, indexPath: IndexPath, source: FocusEligibilitySource) {
        self.container = container
        self.indexPath = indexPath
        self.source = source
    }
}

extension BentoCollectionView {
    func focusCoordinator(for view: UIView) -> FocusCoordinating? {
        if let cell = search(from: view, type: Cell.self),
            let indexPath = indexPath(for: cell),
            let source = dataSource as? FocusEligibilitySource {
            return FocusCoordinator(container: self, indexPath: indexPath, source: source)
        }
        return nil
    }

    @discardableResult
    func focusItem(nextTo indexPath: IndexPath?, direction: FocusSearchDirection, skipsPopulatedComponents: Bool, animated: Bool = false) -> Bool {
        let indexPath = (dataSource as? FocusEligibilitySource)?
            .indexPathOfFocusableComponent(
                nextTo: indexPath,
                direction: direction,
                skipsPopulatedComponents: skipsPopulatedComponents
            )

        if let indexPath = indexPath {
            func focus() -> Bool {
                if let visibleCell = visibleCell(at: indexPath) {
                    (visibleCell.containedView as? FocusableView)?.focus()
                    return true
                }
                return false
            }

            if focus() {
                return true
            } else {
                revealCell(at: indexPath, animated: animated)
                let hasTransferred = focus()
                return hasTransferred
            }
        }

        return false
    }
}
