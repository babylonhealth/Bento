# [Bento](https://en.wikipedia.org/wiki/Bento) 🍱 弁当

> #### is a single-portion take-out or home-packed meal common in Japanese cuisine. A traditional bento holds rice or noodles, fish or meat, with pickled and cooked vegetables, in a box.

**Bento** is a Swift library for building component-based interfaces on top of `UITableView` or `UICollectionView`*

- **Declarative:**  provides a painless approach for building `UI{Table/Collection}View` interfaces
- **Diffing:** reloads your UI with beautiful animations when your data changes
- **Component-based:**  Design reusable components and share your custom UI across multiple screens of your app

In our experience it makes UI-related code easier to build and maintain.  Our aim is to make `UI = f(state)`, which makes `Bento` a perfect fit for Reactive Programming

## Content 📋

- [What's it like?](#whats-it-like)
- [How does it work?](#how-does-it-work)
- [How do components look?](#how-do-components-look)
- [Samples](#samples)
- [Installation](#installation)
- [State of the project](#state-of-the-project)
- [Contribute](#contribute)

### What's it like? 🧐
When building a `Bento`, all you need to care about are `Bento`s and `Node`s.


```swift
let bento = Bento<SectionId, RowId>.empty
                |-+ Section(id: SectionId.user,
                            header: EmptySpaceComponent(height: 24, color: .clear))
                |--+ RowId.user <> IconTitleDetailsComponent(icon: image, title: patient.name)
                |-+ Section(id: SectionId.consultantDate,
                            header: EmptySpaceComponent(height: 24, color: .clear))
                |--+ RowId.loading <> LoadingIndicatorComponent(isLoading: true)
                
tableView.render(bento)
```

### How does it work? 🤔

#### Bento 🍱

The bento is a fundamental component of the library, essentially a virtual representation of the `UI{Table/Collection}View` content. It has two generic parameters - `SectionId` and `RowId` - which are unique identifiers for  `Section<SectionId>` and `Node<RowId>`, used by the [diffing engine](https://github.com/RACCommunity/FlexibleDiff) to perform animated changes of the `UI{Table/Collection}View` content.

#### Sections and Nodes 🏗

A `Section` and a `Node` are building blocks of the `Bento`.

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

#### Identity 🎫
Identity is one of the key concepts in the `Bento` library. Which is used by the diffing algorithm to perform changes.

 > For general business concerns, full inequality of two instances does not necessarily mean inequality in term of identity — it just means the data being held has changed if the identity of both instances is the same.
 
 (More info [here](https://github.com/RACCommunity/FlexibleDiff))

There are `SectionId` and `RowId` which are defining identity of  the `Section` and the `Row` respectively.

#### Renderable 🖼

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

#### Bento's arithmetics 💡

There are several custom operators to work with `Bento`. They provide a syntax sugar to build a `Bento`. The pseudo code looks something like:

```swift
infix operator <>: BitwiseShiftPrecedence
infix operator |-+: AdditionPrecedence
infix operator |--+: MultiplicationPrecedence

let beno = Bento.empty // 3
	|-+ Section() // 2
	|--+ RowId.id <> Component() // 1
```

As you can `<>` has a BitwiseShiftPrecedence, `|--+` has a `MultiplicationPrecedence` and `|-+` has an `AdditionPrecedence `, which means that Nodes will be computed first. The order of the expression above is:

1.  `RowId.id <> Component()` => `Node`
2. `Section() |--+ Node()` => `Section`
3. `Bento() |-+ Section()` => `Bento`

### Examples 😎

Sections | Appoitment | Movies
--- | --- | ---
![](Resources/example1.gif) | ![](Resources/example2.gif) | ![](Resources/example3.gif)

### Installation 💾

* Cocopods

```ruby
target 'MyApp' do
    pod 'Bento'
end
```
* Carthage (TODO)


### State of the project 🤷‍♂️

Feature | Status
--- | ---
`UITableView` | ✅ 
`UICollectionView` | ❌
free functions as alternative to operators | ❌

### Contribute ✍️

Contributions are very welcome and highly appreciated ❤️  

How to contribute: 

- If you have any questions feel free to create  an issue with a `question` label
- If you have a feature request create an issue with a `Feature request` label
- If you found a bug feel free to create an issue with a `bug` label or open a PR with a fix.