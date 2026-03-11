import UIKit

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    
    @IBOutlet var imageCell: UIImageView!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var dateLabel: UILabel!
    
    private let gradientView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let gradientLayer = CAGradientLayer()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupGradientBackground()
    }
    
    private func setupGradientBackground() {
        contentView.insertSubview(gradientView, aboveSubview: imageCell)
        
        NSLayoutConstraint.activate([
            gradientView.leadingAnchor
                .constraint(equalTo: imageCell.leadingAnchor),
            gradientView.trailingAnchor
                .constraint(equalTo: imageCell.trailingAnchor),
            gradientView.bottomAnchor
                .constraint(equalTo: imageCell.bottomAnchor),
            gradientView.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        setupGradientLayer()
        
        gradientView.layer.cornerRadius = 16
        gradientView.layer.maskedCorners = [
            .layerMinXMaxYCorner,
            .layerMaxXMaxYCorner
        ]
        gradientView.clipsToBounds = true
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
        imageCell.image = nil
        dateLabel.text = nil
    }
}
