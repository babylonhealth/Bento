import Bento

/// Represent a component tree that can be presented as the custom input view of
/// a first responder.
///
/// `Box`, `Section` and `Node` by default conforms to `CustomInput` regardless
/// of their type parameters. In other words, you may supply any arbitrary tree
/// represented by these types as `CustomInput`.
///
/// `Component.DatePicker` and `Component.OptionPicker` also conform to this
/// protocol, so you may use these at any place expecting `CustomInput`.
public protocol CustomInput {
    func makeCustomInputBox() -> AnyBox
}

extension Box: CustomInput {
    public func makeCustomInputBox() -> AnyBox {
        return AnyBox(self)
    }
}

extension Section: CustomInput {
    public func makeCustomInputBox() -> AnyBox {
        return AnyBox(Box(sections: [self]))
    }
}

extension Node: CustomInput {
    public func makeCustomInputBox() -> AnyBox {
        return AnyBox(Box(sections: [Section(id: 0, items: [self])]))
    }
}

extension CustomInput where Self: Renderable, Self.View: UIView {
    public func makeCustomInputBox() -> AnyBox {
        return AnyBox(
            Box<Int, Int>.empty
                |-+ Section(id: 0)
                |---+ Node(id: 0, component: self)
        )
    }
}
