import UIKit

final class ImagesListCell: UITableViewCell {

    static let reuseIdentifier = "ImagesListCell"
    
    private enum UIConstants {
        static let cornerRadius: CGFloat = 16
        static let verticalInset: CGFloat = 4
        static let horizontalInset: CGFloat = 16
        static let overlayHeight: CGFloat = 30
        static let overlayEndAlpha: CGFloat = 1.0
    }

    private let cellImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = UIConstants.cornerRadius
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
        button.setImage(UIImage(resource: .likeButtonOn), for: .normal)
        return button
    }()

    private let bottomOverlayView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = false
        view.backgroundColor = .clear
        return view
    }()
    
    private let overlayGradientLayer = CAGradientLayer()

    var imageCell: UIImageView { cellImageView }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor(resource: .ypBlack)
        contentView.addSubview(cellImageView)
        contentView.insertSubview(bottomOverlayView, aboveSubview: cellImageView)
        contentView.addSubview(likeButton)
        contentView.addSubview(dateLabel)
        setupConstraints()
        setupOverlayGradient()
        
        bottomOverlayView.layer.cornerRadius = UIConstants.cornerRadius
        bottomOverlayView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        bottomOverlayView.clipsToBounds = true
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            cellImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: UIConstants.verticalInset),
            cellImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: UIConstants.horizontalInset),
            cellImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -UIConstants.horizontalInset),
            cellImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -UIConstants.verticalInset),
            likeButton.topAnchor.constraint(equalTo: cellImageView.topAnchor),
            likeButton.trailingAnchor.constraint(equalTo: cellImageView.trailingAnchor),
            likeButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 44),
            likeButton.heightAnchor.constraint(equalToConstant: 44),
            dateLabel.leadingAnchor.constraint(equalTo: cellImageView.leadingAnchor, constant: 8),
            dateLabel.bottomAnchor.constraint(equalTo: cellImageView.bottomAnchor, constant: -8),
            bottomOverlayView.leadingAnchor.constraint(equalTo: cellImageView.leadingAnchor),
            bottomOverlayView.trailingAnchor.constraint(equalTo: cellImageView.trailingAnchor),
            bottomOverlayView.bottomAnchor.constraint(equalTo: cellImageView.bottomAnchor),
            bottomOverlayView.heightAnchor.constraint(equalToConstant: UIConstants.overlayHeight)
        ])
    }
    
    private func setupOverlayGradient() {
        overlayGradientLayer.colors = [
            UIColor(resource: .ypBlack).withAlphaComponent(0.0).cgColor,
            UIColor(resource: .ypBlack).withAlphaComponent(UIConstants.overlayEndAlpha).cgColor
        ]
        overlayGradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        overlayGradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        overlayGradientLayer.locations = [0.0, 1.0]
        
        if overlayGradientLayer.superlayer == nil {
            bottomOverlayView.layer.insertSublayer(overlayGradientLayer, at: 0)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        overlayGradientLayer.frame = bottomOverlayView.bounds
        contentView.bringSubviewToFront(dateLabel)
        contentView.bringSubviewToFront(likeButton)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        cellImageView.image = nil
        dateLabel.text = nil
    }
}
