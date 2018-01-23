
public protocol Component: Renderable {

    func componentWillMount()

    func componentWillUnmount()
}
