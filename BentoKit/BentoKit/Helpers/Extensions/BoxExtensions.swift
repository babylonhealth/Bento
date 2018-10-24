import Bento

extension Box {
    func tableViewHeightBoundTo(width: CGFloat, inheritedMargins: UIEdgeInsets) -> CGFloat {
        return sections.reduce(into: 0) { height, section in
            height += section.tableViewHeightBoundTo(width: width, inheritedMargins: inheritedMargins)
        }
    }
}

private extension Section {
    func tableViewHeightBoundTo(width: CGFloat, inheritedMargins: UIEdgeInsets) -> CGFloat {
        return footerHeightBoundTo(width: width, inheritedMargins: inheritedMargins)
            + headerHeightBoundTo(width: width, inheritedMargins: inheritedMargins)
            + items.reduce(0) { height, row in
                height + row.heightBoundTo(width: width, inheritedMargins: inheritedMargins)
        }
    }

    func footerHeightBoundTo(width: CGFloat, inheritedMargins: UIEdgeInsets) -> CGFloat {
        if let component = component(of: .footer, as: HeightCustomizing.self) {
            return component.height(forWidth: width, inheritedMargins: inheritedMargins)
        }
        return componentSize(of: .footer, fittingWidth: width, inheritedMargins: inheritedMargins)?.height ?? 0
    }

    func headerHeightBoundTo(width: CGFloat, inheritedMargins: UIEdgeInsets) -> CGFloat {
        if let component = component(of: .header, as: HeightCustomizing.self) {
            return component.height(forWidth: width, inheritedMargins: inheritedMargins)
        }
        return componentSize(of: .header, fittingWidth: width, inheritedMargins: inheritedMargins)?.height ?? 0
    }
}

private extension Node {
    func heightBoundTo(width: CGFloat, inheritedMargins: UIEdgeInsets) -> CGFloat {
        if let component = component(as: HeightCustomizing.self) {
            return component.height(forWidth: width, inheritedMargins: inheritedMargins)
        }
        return sizeBoundTo(width: width).height
    }
}
