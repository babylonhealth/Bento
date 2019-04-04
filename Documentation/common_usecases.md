#Common UseCases
## Invoke action while tapping on a cell
The effect is similar to using `tableView(_:didSelectRowAt:)` method on `UITableViewDelegate`. You need to do few steps to be able to react on tapping on a cell.
1. `BentoKit` has a class named `InteractiveView`. Your component's view needs to inherit from this class.
2. Add `didTap: (() -> Void)?` closure to your component's init.
3. Bind `didTap` with the component view's `highlightingGesture` property in the component's `render(in:)` function:
```swift
//didTap's type is (() -> Void)?
view.highlightingGesture.didTap = didTap.map(HighlightingGesture.TapAction.resign)
```