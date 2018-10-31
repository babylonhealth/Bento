import UIKit

extension UIView {
    func add(to container: UIView) -> Self {
        container.addSubview(self)
        return self
    }

    func pinEdges(to view: UIView, insets: UIEdgeInsets = .zero) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: view.topAnchor, constant: insets.top),
            bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: insets.bottom),
            leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: insets.left),
            trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: insets.right)
        ])
    }

    func pinEdges(to layoutGuide: UILayoutGuide,
                  insets: UIEdgeInsets = .zero,
                  topPriority: UILayoutPriority = .required,
                  bottomPriority: UILayoutPriority = .required,
                  leadingPrioryty: UILayoutPriority = .required,
                  trailingPriority: UILayoutPriority = .required) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: layoutGuide.topAnchor, constant: insets.top)
                .withPriority(topPriority),
            bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor, constant: insets.bottom)
                .withPriority(bottomPriority),
            leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor, constant: insets.left)
                .withPriority(leadingPrioryty),
            trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor, constant: insets.right)
                .withPriority(trailingPriority)
        ])
    }

    @discardableResult
    func pinCenterX(to anchor: NSLayoutXAxisAnchor) -> Self {
        translatesAutoresizingMaskIntoConstraints = false
        centerXAnchor.constraint(equalTo: anchor).activated()
        return self
    }

    @discardableResult
    func pinCenter(to view: UIView) -> Self {
        translatesAutoresizingMaskIntoConstraints = false

        centerXAnchor.constraint(equalTo: view.centerXAnchor).activated()
        centerYAnchor.constraint(equalTo: view.centerYAnchor).activated()

        return self
    }

    @discardableResult
    func pinCenterY(to anchor: NSLayoutYAxisAnchor) -> Self {
        translatesAutoresizingMaskIntoConstraints = false
        centerYAnchor.constraint(equalTo: anchor).activated()
        return self
    }

    @discardableResult
    func pinTop(to view: UIView, constant: CGFloat = 0.0) -> Self {
        translatesAutoresizingMaskIntoConstraints = false
        view.topAnchor.constraint(equalTo: topAnchor, constant: constant).activated()
        return self
    }

    @discardableResult
    func pinTop(to layoutGuide: UILayoutGuide, constant: CGFloat = 0.0) -> Self {
        translatesAutoresizingMaskIntoConstraints = false
        layoutGuide.topAnchor.constraint(equalTo: topAnchor, constant: constant).activated()
        return self
    }

    @discardableResult
    func pinBottom(to view: UIView) -> Self {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
        return self
    }

    @discardableResult
    func pinBottom(to layoutGuide: UILayoutGuide) -> Self {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            layoutGuide.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
        return self
    }

    @discardableResult
    func centerInSuperview() -> Self {
        translatesAutoresizingMaskIntoConstraints = false
        guard let superview = self.superview else { return self }

        NSLayoutConstraint.activate([
            centerXAnchor.constraint(equalTo: superview.centerXAnchor),
            centerYAnchor.constraint(equalTo: superview.centerYAnchor)
        ])

        return self
    }


    @discardableResult
    func width(_ width: CGFloat) -> Self {
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalToConstant: width).activated()
        return self
    }

    @discardableResult
    func height(_ height: CGFloat, priority: UILayoutPriority = .required) -> Self {
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: height)
            .withPriority(priority)
            .activated()
        return self
    }
}

func stack(_ axis: NSLayoutConstraint.Axis,
           spacing: CGFloat = 0,
           distribution: UIStackView.Distribution = .fill,
           alignment: UIStackView.Alignment = .fill) -> (_ views: UIView...) -> UIStackView {
    return { (views: UIView...) in
        stack(axis, spacing: spacing, distribution: distribution, alignment: alignment, views: views)
    }
}

func stack(_ axis: NSLayoutConstraint.Axis,
           spacing: CGFloat = 0,
           distribution: UIStackView.Distribution = .fill,
           alignment: UIStackView.Alignment = .fill,
           views: [UIView]) -> UIStackView {
    views.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
    let stackView = UIStackView(arrangedSubviews: views)
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.axis = axis
    stackView.spacing = spacing
    stackView.distribution = distribution
    stackView.alignment = alignment
    return stackView
}
