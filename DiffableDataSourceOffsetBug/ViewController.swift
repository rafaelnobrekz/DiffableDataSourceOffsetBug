//
//  ViewController.swift
//  DiffableDataSourceOffsetBug
//
//  Created by Rafael Nobre on 11/04/23.
//

import UIKit
import DiffableDataSources

typealias NSDiffableDataSourceSnapshot = DiffableDataSourceSnapshot
typealias UICollectionViewDiffableDataSource = CollectionViewDiffableDataSource
typealias UITableViewDiffableDataSource = TableViewDiffableDataSource

enum Section: Hashable {
    case list
}

struct DiffableItem: Hashable {
    let id: String
    let title: String
    var isSelected: Bool

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(title)
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.hashValue == rhs.hashValue && lhs.isSelected == rhs.isSelected
    }
}

class ViewController: UIViewController, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(DiffableTestCell.self, forCellReuseIdentifier: DiffableTestCell.identifier)
        tableView.allowsMultipleSelection = true
        tableView.delegate = self

        let initialItems: [DiffableItem] = Array(1...30).map { DiffableItem(id: "\($0)", title: "Item #\($0)", isSelected: false)}
        applySnapshot(initialItems, animated: false)
    }

    private lazy var dataSource: UITableViewDiffableDataSource<Section, DiffableItem> = {
        let dataSource = UITableViewDiffableDataSource<Section, DiffableItem>(tableView: tableView) { tableView, indexPath, item in
            let cell = tableView.dequeueReusableCell(withIdentifier: DiffableTestCell.identifier, for: indexPath) as! DiffableTestCell
            if item.isSelected {
                tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            } else {
                tableView.deselectRow(at: indexPath, animated: false)
            }
            cell.configure(with: item)

            return cell
        }
        return dataSource
    }()

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        updateItemSelection(true, at: indexPath)
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        updateItemSelection(false, at: indexPath)
    }

    private func updateItemSelection(_ isSelected: Bool, at indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        var items = dataSource.snapshot().itemIdentifiers
        if let index = items.firstIndex(where: { $0.hashValue == item.hashValue }) {
            items[index].isSelected = isSelected
            applySnapshot(items, animated: false)
        }
    }

    private func applySnapshot(_ items: [DiffableItem], animated: Bool, completion: (() -> Void)? = nil) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, DiffableItem>()

        snapshot.appendSections([.list])
        snapshot.appendItems(items)

        dataSource.apply(snapshot, animatingDifferences: animated, completion: completion)
    }

}

class DiffableTestCell: UITableViewCell {
    static let identifier = "DiffableTestCellIdentifier"

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with item: DiffableItem) {
        textLabel?.text = item.title
        detailTextLabel?.text = "id: \(item.id)"
        configureForState()
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)

        configureForState()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        configureForState()
    }

    private func configureForState() {
        let shouldHighlightCell = isHighlighted || isSelected
        contentView.layer.borderColor = shouldHighlightCell ? UIColor.purple.cgColor : UIColor.lightGray.cgColor
        contentView.layer.borderWidth = shouldHighlightCell ? 3 : 1
        contentView.backgroundColor = shouldHighlightCell ? .purple.withAlphaComponent(0.4) : .white
        textLabel?.textColor = shouldHighlightCell ? .purple : .black
    }

}
