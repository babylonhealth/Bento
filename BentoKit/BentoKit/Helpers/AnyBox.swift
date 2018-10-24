import Bento

public struct AnyBox {
    private let base: AnyBoxInternalBase

    public var type: Any.Type {
        return base.type
    }

    public init<SectionID, ItemID>(_ box: Box<SectionID, ItemID>) {
        base = AnyBoxInternal(box)
    }

    /// Render the type erased box to the specified `UITableView`. If the
    /// `UITableView` has already been prepared with a different section ID type
    /// or item ID type, this would cause a runtime trap in Bento.
    public func unsafeRender(in tableView: UITableView, animated: Bool = true) {
        base.render(in: tableView, animated: animated)
    }

    public func tableViewHeightBoundTo(width: CGFloat, inheritedMargins: UIEdgeInsets) -> CGFloat {
        return base.tableViewHeightBoundTo(width: width, inheritedMargins: inheritedMargins)
    }
}

private class AnyBoxInternal<SectionID: Hashable, ItemID: Hashable>: AnyBoxInternalBase {
    private let box: Box<SectionID, ItemID>

    public override var type: Any.Type { return Box<SectionID, ItemID>.self }

    public init(_ box: Box<SectionID, ItemID>) {
        self.box = box
    }

    public override func render(in tableView: UITableView, animated: Bool) {
        tableView.render(box, animated: animated)
    }

    public override func tableViewHeightBoundTo(width: CGFloat, inheritedMargins: UIEdgeInsets) -> CGFloat {
        return box.tableViewHeightBoundTo(width: width, inheritedMargins: inheritedMargins)
    }
}

private class AnyBoxInternalBase {
    public var type: Any.Type { fatalError() }

    public func render(in tableView: UITableView, animated: Bool) {
        fatalError("Should have been overriden by AnyBoxInternal.")
    }

    public func tableViewHeightBoundTo(width: CGFloat, inheritedMargins: UIEdgeInsets) -> CGFloat {
        fatalError("Should have been overriden by AnyBoxInternal.")
    }
}
