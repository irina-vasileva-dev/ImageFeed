import UIKit

final class ImagesListCell: UITableViewCell {

    static let reuseIdentifier = "ImagesListCell"

    private let cellImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 16
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = UIColor.white.withAlphaComponent(0.9)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let likeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "like_button_on"), for: .normal)
        return button
    }()

    private let gradientView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let gradientLayer = CAGradientLayer()

    var imageCell: UIImageView { cellImageView }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor(hex: "#1A1B22")
        contentView.addSubview(cellImageView)
        contentView.insertSubview(gradientView, aboveSubview: cellImageView)
        contentView.addSubview(likeButton)
        contentView.addSubview(dateLabel)
        setupConstraints()
        setupGradientLayer()
        gradientView.layer.cornerRadius = 16
        gradientView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        gradientView.clipsToBounds = true
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        if gradientView.superview == nil {
            setupGradientBackground()
        }
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            cellImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            cellImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cellImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cellImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            likeButton.topAnchor.constraint(equalTo: cellImageView.topAnchor),
            likeButton.trailingAnchor.constraint(equalTo: cellImageView.trailingAnchor),
            likeButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 44),
            likeButton.heightAnchor.constraint(equalToConstant: 44),
            dateLabel.leadingAnchor.constraint(equalTo: cellImageView.leadingAnchor, constant: 8),
            dateLabel.bottomAnchor.constraint(equalTo: cellImageView.bottomAnchor, constant: -8),
            gradientView.leadingAnchor.constraint(equalTo: cellImageView.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: cellImageView.trailingAnchor),
            gradientView.bottomAnchor.constraint(equalTo: cellImageView.bottomAnchor),
            gradientView.heightAnchor.constraint(equalToConstant: 30)
        ])
    }

    private func setupGradientBackground() {
        contentView.insertSubview(gradientView, aboveSubview: cellImageView)
        NSLayoutConstraint.activate([
            gradientView.leadingAnchor.constraint(equalTo: cellImageView.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: cellImageView.trailingAnchor),
            gradientView.bottomAnchor.constraint(equalTo: cellImageView.bottomAnchor),
            gradientView.heightAnchor.constraint(equalToConstant: 30)
        ])
        gradientView.layer.cornerRadius = 16
        gradientView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        gradientView.clipsToBounds = true
        setupGradientLayer()
    }

    private func setupGradientLayer() {
        gradientLayer.colors = [
            UIColor(hex: "1A1B22").withAlphaComponent(0.0).cgColor,
            UIColor(hex: "1A1B22").withAlphaComponent(1.0).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.locations = [0.0, 1.0]
        gradientView.layer.insertSublayer(gradientLayer, at: 0)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = gradientView.bounds
        contentView.bringSubviewToFront(dateLabel)
        contentView.bringSubviewToFront(likeButton)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        cellImageView.image = nil
        dateLabel.text = nil
    }
}
