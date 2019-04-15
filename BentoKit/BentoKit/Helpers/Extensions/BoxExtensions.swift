import Bento

extension Box {
    public func tableViewHeightBoundTo(width: CGFloat, inheritedMargins: UIEdgeInsets) -> CGFloat {
        return sections.reduce(into: 0) { height, section in
            height += section.tableViewHeightBoundTo(width: width, inheritedMargins: inheritedMargins)
        }
    }
}

extension Section {
    public func tableViewHeightBoundTo(width: CGFloat, inheritedMargins: UIEdgeInsets) -> CGFloat {
        return footerHeightBoundTo(width: width, inheritedMargins: inheritedMargins)
            + headerHeightBoundTo(width: width, inheritedMargins: inheritedMargins)
            + items.reduce(0) { height, row in
                height + row.heightBoundTo(width: width, inheritedMargins: inheritedMargins)
        }
    }

    fileprivate func footerHeightBoundTo(width: CGFloat, inheritedMargins: UIEdgeInsets) -> CGFloat {
        guard let footer = supplements[.footer] else { return 0.0 }

        if let component = footer.cast(to: HeightCustomizing.self) {
            return component.height(forWidth: width, inheritedMargins: inheritedMargins)
        }

        return footer.size(fittingWidth: width, inheritedMargins: inheritedMargins).height
    }

    fileprivate func headerHeightBoundTo(width: CGFloat, inheritedMargins: UIEdgeInsets) -> CGFloat {
        guard let header = supplements[.header] else { return 0.0 }

        if let component = header.cast(to: HeightCustomizing.self) {
            return component.height(forWidth: width, inheritedMargins: inheritedMargins)
        }

        return header.size(fittingWidth: width, inheritedMargins: inheritedMargins).height
    }
}

extension Node {
    fileprivate func heightBoundTo(width: CGFloat, inheritedMargins: UIEdgeInsets) -> CGFloat {
        if let component = component.cast(to: HeightCustomizing.self) {
            return component.height(forWidth: width, inheritedMargins: inheritedMargins)
        }
        return component.size(fittingWidth: width, inheritedMargins: inheritedMargins).height
    }
}
