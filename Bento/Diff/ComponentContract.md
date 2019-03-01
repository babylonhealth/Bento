## Bento Component Contract
Applicable to both UICollectionView and UITableView.

### Components must conform to `Renderable`.
`Renderable` represents a set of requirements which a component must satisfy for Bento to integrate it.

### Components need not be evaluable for equation.
Bento enforces no restriction in what types of properties the component can comprise of. Moreover, there are also prevalent uses of non-equatable properties, for example, user interaction callbacks. Therefore, Bento does not require any component to be evaluable for equation.

### Any given ID path may be bound with any kind and instance of components at any time.
Bento is designed to be very flexible in terms of component types. Users should require no extra precaution in populating their `Box`es with different permutations of ID paths and components.

### Visible ID paths may be aggressively rebound.
[As Bento cannot rely on component equation](#components-need-not-be-evaluable-for-equation), Bento aggressively rebinds all visible ID paths with the new component at the same ID path in any new `Box` being applied.

### Components should avoid deriving animations from rebinding occurrences.
[Given potential occurrences of aggressive rebinding](#visible-id-paths-may-be-aggressively-rebound), rebinding is generally not a good indiction of when animations should happen. Components might want to instead have data-driven, fine-grained animations, or rely on mechanisms like `ViewLifecycleAware`. 

### Behaviors may be attached to any component freely.
Bento supports composition of opt-in behaviors, for example swipe-to-delete and lifecycle observation, without needing the augmented component type to have implemented these beforehand.

### Behaviors and Components MUST not offer any customization point which allows direct access to any part of the view hierarchy.
Customization point, that vends any point of the view hierarchy to the user directly, would imply changes being irreversable and undiscoverable. This has serious implications when the view would be recycled by the container, where those changes may be carried to the next bound component unintendedly, and in turn lead to indeterministic results.
 
Provide a declarative API by asking for information covering all supported scenarios. Use the collected data to manipulate the view hierarchy accordingly, and make sure all branched scenarios would erase the trails of each other properly.
