import UIKit

final class ProfileViewController: UIViewController {
    
    // MARK: - UI Elements
    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = Constants.stackViewSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "profile_image")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var userNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Екатерина Новикова"
        label.font = .boldSystemFont(ofSize: Constants.boldFontSize)
        label.textColor = .white
        return label
    }()
    
    private lazy var nickNameLabel: UILabel = {
        let label = UILabel()
        label.text = "@ekaterina_nov"
        label.font = .systemFont(ofSize: Constants.detailFontSize)
        label.textColor = Colors.nicknameGray
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Hello, world!"
        label.font = .systemFont(ofSize: Constants.detailFontSize)
        label.textColor = .white
        return label
    }()
    
    private lazy var logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "logout"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var favoritesLabel: UILabel = {
        let label = UILabel()
        label.text = "Избранное"
        label.font = .boldSystemFont(ofSize: Constants.boldFontSize)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var noPhotoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "no_photo")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        view.backgroundColor = Colors.background
        
        configureProfileImageView()
        setupStackViewHierarchy()
        addSubviews()
    }
    
    private func configureProfileImageView() {
        NSLayoutConstraint.activate([
            profileImageView.heightAnchor.constraint(equalToConstant: Constants.profileImageSize),
            profileImageView.widthAnchor.constraint(equalToConstant: Constants.profileImageSize)
        ])
        
        NSLayoutConstraint.activate([
            logoutButton.heightAnchor.constraint(equalToConstant: Constants.buttonSize),
            logoutButton.widthAnchor.constraint(equalToConstant: Constants.buttonSize)
        ])
    }
    
    private func setupStackViewHierarchy() {
        mainStackView.addArrangedSubview(profileImageView)
        mainStackView.addArrangedSubview(userNameLabel)
        mainStackView.addArrangedSubview(nickNameLabel)
        mainStackView.addArrangedSubview(descriptionLabel)
    }
    
    private func addSubviews() {
        view.addSubview(mainStackView)
        view.addSubview(logoutButton)
        view.addSubview(favoritesLabel)
        view.addSubview(noPhotoImageView)
    }
    
    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(
                equalTo: safeArea.topAnchor,
                constant: Constants.stackViewTopOffset
            ),
            mainStackView.leadingAnchor.constraint(
                equalTo: safeArea.leadingAnchor,
                constant: Constants.stackViewLeadingOffset
            ),
            logoutButton.trailingAnchor.constraint(
                equalTo: safeArea.trailingAnchor,
                constant: -Constants.buttonTrailingOffset
            ),
            logoutButton.centerYAnchor.constraint(
                equalTo: profileImageView.centerYAnchor
            ),
            favoritesLabel.leadingAnchor.constraint(
                equalTo: safeArea.leadingAnchor,
                constant: Constants.favoritesLabelLeading
            ),
            favoritesLabel.topAnchor.constraint(
                equalTo: descriptionLabel.bottomAnchor,
                constant: Constants.favoritesLabelTop
            ),
            noPhotoImageView.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            noPhotoImageView.topAnchor.constraint(
                equalTo: safeArea.topAnchor,
                constant: Constants.noPhotoTop
            ),
            noPhotoImageView.heightAnchor.constraint(equalToConstant: Constants.noPhotoImageSize),
            noPhotoImageView.widthAnchor.constraint(equalToConstant: Constants.noPhotoImageSize)
        ])
    }
    
    // MARK: - Actions
    @objc private func logoutButtonTapped() {
        removeAllLabels()
    }
    
    private func removeAllLabels() {
        view.subviews
            .compactMap { $0 as? UILabel }
            .forEach { $0.removeFromSuperview() }
    }
}

// MARK: - Constants
private enum Constants {
    static let stackViewSpacing: CGFloat = 8
    static let stackViewTopOffset: CGFloat = 32
    static let stackViewLeadingOffset: CGFloat = 16
    static let buttonTrailingOffset: CGFloat = 16
    static let profileImageSize: CGFloat = 70
    static let buttonSize: CGFloat = 44
    static let boldFontSize: CGFloat = 23
    static let detailFontSize: CGFloat = 13
    
    static let favoritesLabelLeading: CGFloat = 16
    static let favoritesLabelTop: CGFloat = 24
    
    static let noPhotoImageSize: CGFloat = 115
    static let noPhotoLeadingTrailing: CGFloat = 130
    static let noPhotoTop: CGFloat = 376
}

private enum Colors {
    static let background = UIColor(hex: "#1A1B22")
    static let nicknameGray = UIColor(hex: "#AEAFB4")
}
