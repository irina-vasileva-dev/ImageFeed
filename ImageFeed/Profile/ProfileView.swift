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
        static let favoritesTableTop: CGFloat = 8

        static let favoritesCountBadgeHeight: CGFloat = 22
        static let favoritesCountPaddingLeadingTrailing: CGFloat = 12
        static let favoritesCountPaddingTopBottom: CGFloat = 2

        static let favoritesCountCornerRadius: CGFloat = 11
        static let favoritesTitleToBadgeSpacing: CGFloat = 10
    }

    private enum Colors {
        static let background = UIColor(resource: .ypBlack)
        static let nicknameGray = UIColor(resource: .nicknameGray)
        static let ypBlue = UIColor(resource: .ypBlue)
    }

    private(set) lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(resource: .userStub)
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
        button.setImage(UIImage(resource: .logout), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addAction(
            UIAction { [weak self] _ in
                self?.logoutButtonTapped()
            },
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
        label.text = Constants.favorites
        label.font = .boldSystemFont(ofSize: UIConstants.boldFontSize)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var favoritesCountBadge: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.ypBlue
        view.layer.cornerRadius = UIConstants.favoritesCountCornerRadius
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private(set) lazy var favoritesCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: UIConstants.detailFontSize, weight: .medium)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private(set) lazy var favoritesTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = Colors.background
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 12, right: 0)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    private lazy var noPhotoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(resource: .noPhoto)
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
        addSubview(favoritesCountBadge)
        favoritesCountBadge.addSubview(favoritesCountLabel)
        addSubview(favoritesTableView)
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
            favoritesCountBadge.leadingAnchor
                .constraint(
                    equalTo: favoritesLabel.trailingAnchor,
                    constant: UIConstants.favoritesTitleToBadgeSpacing
                ),
            favoritesCountBadge.centerYAnchor
                .constraint(equalTo: favoritesLabel.centerYAnchor),
            favoritesCountBadge.heightAnchor
                .constraint(equalToConstant: UIConstants.favoritesCountBadgeHeight),
            favoritesCountLabel.leadingAnchor
                .constraint(
                    equalTo: favoritesCountBadge.leadingAnchor,
                    constant: UIConstants.favoritesCountPaddingLeadingTrailing
                ),
            favoritesCountLabel.trailingAnchor
                .constraint(
                    equalTo: favoritesCountBadge.trailingAnchor,
                    constant: -UIConstants.favoritesCountPaddingLeadingTrailing
                ),
            favoritesCountLabel.topAnchor
                .constraint(
                    equalTo: favoritesCountBadge.topAnchor,
                    constant: UIConstants.favoritesCountPaddingTopBottom
                ),
            favoritesCountLabel.bottomAnchor
                .constraint(
                    equalTo: favoritesCountBadge.bottomAnchor,
                    constant: -UIConstants.favoritesCountPaddingTopBottom
                ),
            favoritesTableView.topAnchor
                .constraint(
                    equalTo: favoritesLabel.bottomAnchor,
                    constant: UIConstants.favoritesTableTop
                ),
            favoritesTableView.leadingAnchor
                .constraint(equalTo: safe.leadingAnchor),
            favoritesTableView.trailingAnchor
                .constraint(equalTo: safe.trailingAnchor),
            favoritesTableView.bottomAnchor
                .constraint(equalTo: safe.bottomAnchor),
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

    private func logoutButtonTapped() {
        onLogoutTapped?()
    }
    
    func setFavoritesCount(_ count: Int) {
        favoritesCountLabel.text = "\(count)"
        favoritesCountBadge.isHidden = count == 0
    }
    
    func setEmptyFavoritesVisible(_ isVisible: Bool) {
        noPhotoImageView.isHidden = !isVisible
        favoritesTableView.isHidden = isVisible
    }
}
