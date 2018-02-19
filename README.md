# Forms

`Forms` is a Swift library for building component-based interfaces on top of `UITableView` or `UICollectionView`*

- **Declarative:** `Forms` provides painless approach for building `UI{Table/Collection}View` interfaces. 
- **Diffing:** Forms reload your UI with beautiful animations when your data changes
- **Component-based:**  Desing reusable components and share your custom UI across multiple screens of your app

In our experience, it makes UI related code easier to build and maintain.  Our aim is to make `UI = f(state)` which makes `Forms` perfect fit for Reactive Programming

## Content

- [What's it like?](#whats-it-like)
- [How does it work?](#how-does-it-work)
- [How do components look?](#how-do-components-look)
- [Samples](#samples)
- [Installation](#installation)
- [State of the project](#state-of-the-project)
- [Contribute](#contribute)

### What's it like?
When you want to build a `Form` what you need to care about is only `Section` and `Node`.


```swift
let form = Form<SectionId, RowId>.empty
                |-+ Section(id: SectionId.user,
                            header: EmptySpaceComponent(height: 24, color: .clear))
                |--+ Node(id: RowId.user,
                          component: IconTitleDetailsComponent(icon: image,
                                                               title: patient.name))
                |-+ Section(id: SectionId.consultantDate,
                            header: EmptySpaceComponent(height: 24, color: .clear))
                |--+ Node(id: RowId.loading, 
                            component: LoadingIndicatorComponent(isLoading: true))
                
tableView.render(form: form)
```

### How does it work?

#### Form

The form is a fundamental component of the `Forms` library, essentially it's virtual representation of the `UI{Table/Collection}View` content. It has two generic parameters `Form<SectionId, RowId>`. `SectionId` and `RowId` are unique identifiers of the `Section<SectionId>` and the `Node<RowId>` which are used by the [diffing engine](https://github.com/RACCommunity/FlexibleDiff) to perform animated changes of `UI{Table/Collection}View` content.

#### Sections and Nodes

A `Section` and a `Node` are building blocks of the `Form`.

The `Section` is an abstraction of `UI{Table/Collection}View` section, it defines whether there going to be any header or footer.

The `Node` is an abstraction of `UI{Table/Collection}View` row, it defines how it going be rendered.

```swift
struct Section<SectionId: Hashable, RowId: Hashable> {
    let id: SectionId
    let header: HeaderFooterNode?
    let footer: HeaderFooterNode?
    let rows: [Node<RowId>]
}

public struct Node<Identifier: Hashable> {
    let id: Identifier
    let component: AnyRenderable
}
```

#### Identity
Identity is one of the key concepts in the `Forms` library. Which is used by the diffing algorithm to perform changes.

 > For general business concerns, full inequality of two instances does not necessarily mean inequality in term of identity — it just means the data being held has changed if the identity of both instances is the same.
 
 (More info [here](https://github.com/RACCommunity/FlexibleDiff))

There are `SectionId` and `RowId` which are defining identity of  the `Section` and the `Row` respectively.

#### Renderable

`Renderable` is something similar to the [Component](https://reactjs.org/docs/react-component.html) in the [React](https://github.com/facebook/react). It's an abstraction of the real `UI{Table/Collection}ViewCell` that is going to be displayed. The idea is to make it possible to develop small independent components that can be reused across many parts of your app

```swift
public protocol Renderable: class {
    associatedtype View: UIView
    
    func render(in view: View)
}

class IconTextComponent: Renderable {
    private let title: String
    private let image: UIImage

    init(image: UIImage,
         title: String) {
        self.image = image
        self.title = title
    }

    func render(in view: IconTextCell) {
        view.titleLabel.text = title
        view.iconView.image = image
    }
}
```

#### Forms arithmetics

There are several custom operators to work with `Forms`. They provide a syntax sugar to build a `Form`. The pseudo code looks something like:

```swift
infix operator |-+: AdditionPrecedence
infix operator |--+: MultiplicationPrecedence

let form = Form.empty // 3.
	|-+ Section() // 1.
	|--+ Node()
	|--+ Node()
	|-+ Section() // 2
	|--+ Node()
	|--+ Node()
```

As you can see `|--+` has a `MultiplicationPrecedence` and `|-+` has an `AdditionPrecedence `, which means that Nodes will be computed first. The order of the expression above is:

1. `Section() |--+ Node()` => `Section()`
2. `Section() |--+ Node()` => `Section()`
3. `Form() |-+ Section()` => `Form()`

### Samples

TODO

### Installation

TODO


### State of the project

Feature | Status
--- | ---
`UITableView` | ✅ 
`UICollectionView` | ❌

### Contribute

Contributions are very welcome and highly appreciated ❤️  

How to contribute: 

- If you have any questions feel free to create  an issue with a `question` label
- If you have a feature request create an issue with a `Feature request` label
- If you found a bug feel free to create an issue with a `bug` label or open a PR with a fix.