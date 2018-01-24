import UIKit
import FlexibleDiff

public final class FormTableViewDataSource<Identifier: Hashable>: NSObject, UITableViewDataSource {
    private var items: [FormItem<Identifier>]
    private weak var tableView: UITableView?

    public init(for tableView: UITableView) {
        self.items = []
        self.tableView = tableView
        super.init()
    }

    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let component = items[indexPath.row].component
        if let cell = tableView.dequeueReusableCell(withIdentifier: component.reuseIdentifier) as? TableViewCell {
            let componentView: UIView
            if let containedView = cell.containedView {
                componentView = containedView
            } else {
                componentView = component.generator()
                cell.install(view: componentView)
            }
            component.render(in: componentView)
            return cell
        } else {
            tableView.register(TableViewCell.self, forCellReuseIdentifier: component.reuseIdentifier)
            return self.tableView(tableView, cellForRowAt: indexPath)
        }
    }

    public func update(with newItems: [FormItem<Identifier>]) {
        guard let tableView = self.tableView else { return }
        tableView.endEditing(true)
        let changeset = Changeset(previous: self.items, current: newItems,
                                  identifier: DiffIdentifier.init,
                                  areEqual: { $0.component === $1.component })
        self.items = newItems
        let deletedRows: [IndexPath] = changeset.removals.map { [0, $0] }
        let insertedRows: [IndexPath] = changeset.inserts.map { [0, $0] }
        tableView.beginUpdates()
        tableView.deleteRows(at: deletedRows, with: .fade)
        tableView.insertRows(at: insertedRows, with: .fade)
        [changeset.moves.lazy
            .flatMap { $0.isMutated ? ($0.source, $0.destination) : nil },
         changeset.mutations.lazy.map { ($0, $0) }]
            .joined()
            .forEach { source, destination in
                guard
                    let cell = tableView.cellForRow(at: [0, source]) as? TableViewCell,
                    let componentView = cell.containedView
                    else { fatalError() }
                self.items[destination].component.render(in: componentView)
            }
        tableView.endUpdates()
    }

    private struct DiffIdentifier: Hashable {
        private let id: Identifier

        var hashValue: Int {
            return id.hashValue
        }

        init(_ item: FormItem<Identifier>) {
            self.id = item.id
        }

        static func == (left: DiffIdentifier, right: DiffIdentifier) -> Bool {
            return left.id == right.id
        }
    }
}

class TableViewCell: UITableViewCell {

    var containedView: UIView? = nil

    func install(view: UIView) {
        self.containedView = view

        contentView.addSubview(view)

        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: contentView.topAnchor),
            view.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            view.rightAnchor.constraint(equalTo: contentView.rightAnchor)
            ])
    }
}
