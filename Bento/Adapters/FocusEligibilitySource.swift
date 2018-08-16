internal protocol FocusEligibilitySource: AnyObject {
    func indexPathOfFocusableComponent(nextTo indexPath: IndexPath?, direction: FocusSearchDirection, skipsPopulatedComponents: Bool) -> IndexPath?
}

internal protocol FocusEligibilitySourceImplementing: FocusEligibilitySource {
    associatedtype SectionId: Hashable
    associatedtype NodeId: Hashable

    var sections: [Section<SectionId, NodeId>] { get }
}

extension FocusEligibilitySourceImplementing {
    func indexPathOfFocusableComponent(nextTo indexPath: IndexPath?, direction: FocusSearchDirection, skipsPopulatedComponents: Bool) -> IndexPath? {
        let sections = self.sections

        switch direction {
        case .backward:
            let indexPath = indexPath ?? IndexPath(item: -1, section: 0)
            var startItemIndex = indexPath.item + 1

            for sectionIndex in indexPath.section ..< sections.endIndex {
                let items = sections[sectionIndex].items

                for itemIndex in startItemIndex ..< items.endIndex {
                    if let component = items[itemIndex].component(as: Focusable.self),
                       component.focusEligibility.isEligible(skipsPopulatedComponents: skipsPopulatedComponents) {
                        return IndexPath(item: itemIndex, section: sectionIndex)
                    }
                }

                startItemIndex = 0
            }

            return nil

        case .forward:
            let indexPath = indexPath ?? IndexPath(item: sections.last?.items.endIndex ?? 0,
                                                   section: max(sections.endIndex - 1, 0))
            var exclusiveNodeUpperBound = indexPath.item

            for sectionIndex in (sections.startIndex ... indexPath.section).reversed() {
                let items = sections[sectionIndex].items

                for itemIndex in (items.startIndex ..< exclusiveNodeUpperBound).reversed() {
                    if let component = items[itemIndex].component(as: Focusable.self),
                       component.focusEligibility.isEligible(skipsPopulatedComponents: skipsPopulatedComponents) {
                        return IndexPath(item: itemIndex, section: sectionIndex)
                    }
                }

                exclusiveNodeUpperBound = sectionIndex == sections.startIndex
                    ? 0
                    : sections[sectionIndex - 1].items.endIndex
            }

            return nil
        }
    }
}
