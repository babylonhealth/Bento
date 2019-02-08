/// Specify whether the layouts of two instances of the same component are equivalent to each other.
public enum LayoutEquivalence {
    /// The layouts are the same, and Bento may reuse any cached layout parameter.
    case same

    /// The layouts should be different from each other, and Bento must invalidate any cached layout parameter.
    case different

    /// The component does not have a definition of layout equivalence. Bento must treat all instances as always
    /// different from each other.
    public static var unknown: LayoutEquivalence { return .different }
}
