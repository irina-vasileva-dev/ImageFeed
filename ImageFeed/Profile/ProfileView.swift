import UIKit

final class ProfileView: UIView {

    var onLogoutTapped: (() -> Void)?

    private enum UIConstants {
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
        static let noPhotoTop: CGFloat = 376
    }

    private enum Colors {
        static let background = UIColor(hex: "#1A1B22")
        static let nicknameGray = UIColor(hex: "#AEAFB4")
    }

    private enum Assets {
        static let noPhoto = "no_photo"
        static let favorites = "Избранное"
        static let logout = "logout"
        static let profileImage = "profile_image"
    }

    private(set) lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: Assets.profileImage)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private(set) lazy var userNameLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: UIConstants.boldFontSize)
        label.textColor = .white
        return label
    }()

    private(set) lazy var loginNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: UIConstants.detailFontSize)
        label.textColor = Colors.nicknameGray
        return label
    }()

    private(set) lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: UIConstants.detailFontSize)
        label.textColor = .white
        return label
    }()

    private(set) lazy var logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: Assets.logout), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button
            .addTarget(
                self,
                action: #selector(logoutButtonTapped),
                for: .touchUpInside
            )
        return button
    }()

    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = UIConstants.stackViewSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private lazy var favoritesLabel: UILabel = {
        let label = UILabel()
        label.text = Assets.favorites
        label.font = .boldSystemFont(ofSize: UIConstants.boldFontSize)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var noPhotoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: Assets.noPhoto)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
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
        backgroundColor = Colors.background
        profileImageView.layer.cornerRadius = UIConstants.profileImageSize / 2
        NSLayoutConstraint.activate([
            profileImageView.heightAnchor
                .constraint(equalToConstant: UIConstants.profileImageSize),
            profileImageView.widthAnchor
                .constraint(equalToConstant: UIConstants.profileImageSize),
            logoutButton.heightAnchor
                .constraint(equalToConstant: UIConstants.buttonSize),
            logoutButton.widthAnchor
                .constraint(equalToConstant: UIConstants.buttonSize)
        ])
        mainStackView.addArrangedSubview(profileImageView)
        mainStackView.addArrangedSubview(userNameLabel)
        mainStackView.addArrangedSubview(loginNameLabel)
        mainStackView.addArrangedSubview(descriptionLabel)
        addSubview(mainStackView)
        addSubview(logoutButton)
        addSubview(favoritesLabel)
        addSubview(noPhotoImageView)
        let safe = safeAreaLayoutGuide
        NSLayoutConstraint.activate(
[
            mainStackView.topAnchor
                .constraint(
                    equalTo: safe.topAnchor,
                    constant: UIConstants.stackViewTopOffset
                ),
            mainStackView.leadingAnchor
                .constraint(
                    equalTo: safe.leadingAnchor,
                    constant: UIConstants.stackViewLeadingOffset
                ),
            logoutButton.trailingAnchor
                .constraint(
                    equalTo: safe.trailingAnchor,
                    constant: -UIConstants.buttonTrailingOffset
                ),
            logoutButton.centerYAnchor
                .constraint(equalTo: profileImageView.centerYAnchor),
            favoritesLabel.leadingAnchor
                .constraint(
                    equalTo: safe.leadingAnchor,
                    constant: UIConstants.favoritesLabelLeading
                ),
            favoritesLabel.topAnchor
                .constraint(
                    equalTo: descriptionLabel.bottomAnchor,
                    constant: UIConstants.favoritesLabelTop
                ),
            noPhotoImageView.centerXAnchor
                .constraint(equalTo: safe.centerXAnchor),
            noPhotoImageView.topAnchor
                .constraint(
                    equalTo: safe.topAnchor,
                    constant: UIConstants.noPhotoTop
                ),
            noPhotoImageView.heightAnchor
                .constraint(equalToConstant: UIConstants.noPhotoImageSize),
            noPhotoImageView.widthAnchor
                .constraint(equalToConstant: UIConstants.noPhotoImageSize)
]
        )
    }

    @objc private func logoutButtonTapped() {
        onLogoutTapped?()
    }

    func removeProfileLabelsFromStack() {
        [userNameLabel, loginNameLabel, descriptionLabel].forEach { label in
            mainStackView.removeArrangedSubview(label)
            label.removeFromSuperview()
        }
    }
}
