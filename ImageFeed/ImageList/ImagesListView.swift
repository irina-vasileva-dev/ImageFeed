import UIKit

final class ImagesListView: UIView {

    private(set) lazy var tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = UIColor(hex: "#1A1B22")
        table.separatorStyle = .none
        table.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.rowHeight = 200
        return table
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        backgroundColor = UIColor(hex: "#1A1B22")
        addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
