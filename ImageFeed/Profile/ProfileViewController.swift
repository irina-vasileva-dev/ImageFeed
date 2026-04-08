import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {

    private let profileService = ProfileService.shared
    private let imagesListService = ImagesListService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    private var imagesListServiceObserver: NSObjectProtocol?
    private var favoritePhotos: [Photo] = []

    private var profileView: ProfileView? { view as? ProfileView }

    private enum UIConstants {
        static let profileImageSize: CGFloat = 70
    }
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = .current
        formatter.dateFormat = "d MMMM yyyy"
        return formatter
    }()

    override func loadView() {
        view = ProfileView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupFavoritesTable()
        profileView?.onLogoutTapped = { [weak self] in
            self?.presentLogoutConfirmation()
        }
        if let profile = ProfileService.shared.profile {
            updateProfileDetails(with: profile)
            if ProfileImageService.shared.avatarURL == nil {
                ProfileImageService.shared.fetchProfileImageURL(username: profile.username) { _ in }
            }
        }
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                self?.updateAvatar()
            }
        imagesListServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ImagesListService.didChangeNotification,
                object: imagesListService,
                queue: .main
            ) { [weak self] _ in
                self?.reloadFavorites()
            }
        updateAvatar()
        reloadFavorites()
    }
    
    deinit {
        if let profileImageServiceObserver {
            NotificationCenter.default.removeObserver(profileImageServiceObserver)
        }
        if let imagesListServiceObserver {
            NotificationCenter.default.removeObserver(imagesListServiceObserver)
        }
    }

    private func updateProfileDetails(with profile: Profile) {
        profileView?.userNameLabel.text = profile.name.isEmpty
            ? "Имя не указано"
            : profile.name
        profileView?.loginNameLabel.text = profile.loginName.isEmpty
            ? "@неизвестный_пользователь"
            : profile.loginName
        profileView?.descriptionLabel.text = (profile.bio?.isEmpty ?? true)
            ? "Профиль не заполнен"
            : profile.bio
    }

    private func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL)
        else { return }
        profileView?.profileImageView.kf.setImage(
            with: url,
            options: [.processor(DownsamplingImageProcessor(size: CGSize(width: UIConstants.profileImageSize * 2, height: UIConstants.profileImageSize * 2)))])
    }
    
    private func setupFavoritesTable() {
        guard let tableView = profileView?.favoritesTableView else { return }
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 200
        tableView.register(
            ImagesListCell.self,
            forCellReuseIdentifier: ImagesListCell.reuseIdentifier
        )
    }
    
    private func presentLogoutConfirmation() {
        let alert = UIAlertController(
            title: "Пока, пока!",
            message: "Уверены, что хотите выйти?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Да", style: .default) { [weak self] _ in
            self?.performLogoutAndReturnToSplash()
        })
        alert.addAction(UIAlertAction(title: "Нет", style: .cancel))
        present(alert, animated: true)
    }

    private func performLogoutAndReturnToSplash() {
        ProfileLogoutService.shared.logout()
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        let splash = SplashViewController()
        window.rootViewController = splash
        window.makeKeyAndVisible()
    }

    private func reloadFavorites() {
        favoritePhotos = imagesListService.photos.filter { $0.isLiked }
        profileView?.setFavoritesCount(favoritePhotos.count)
        profileView?.setEmptyFavoritesVisible(favoritePhotos.isEmpty)
        profileView?.favoritesTableView.reloadData()
    }
}

extension ProfileViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        favoritePhotos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ImagesListCell.reuseIdentifier,
            for: indexPath
        )
        guard let imageListCell = cell as? ImagesListCell else { return cell }
        
        let photo = favoritePhotos[indexPath.row]
        imageListCell.delegate = self
        imageListCell.imageCell.kf.indicatorType = .activity
        
        let placeholder = UIImage(resource: .imagePlaceholder)
        if let url = URL(string: photo.thumbImageURL) {
            imageListCell.imageCell.kf.setImage(with: url, placeholder: placeholder)
        } else {
            imageListCell.imageCell.image = placeholder
        }
        
        if let createdAt = photo.createdAt {
            imageListCell.dateLabel.text = dateFormatter.string(from: createdAt)
        } else {
            imageListCell.dateLabel.text = nil
        }
        imageListCell.setIsLiked(photo.isLiked)
        return imageListCell
    }
}

extension ProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photo = favoritePhotos[indexPath.row]
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = photo.size.width
        guard imageWidth > 0 else { return 0 }
        
        let scale = imageViewWidth / imageWidth
        return photo.size.height * scale + imageInsets.top + imageInsets.bottom
    }
}

extension ProfileViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let tableView = profileView?.favoritesTableView else { return }
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        
        let photo = favoritePhotos[indexPath.row]
        UIBlockingProgressHUD.show()
        imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            guard let self else { return }
            if case .failure = result {
                let alert = UIAlertController(
                    title: "Что-то пошло не так",
                    message: "Не удалось изменить лайк. Попробуйте позже.",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "Ок", style: .default))
                self.present(alert, animated: true)
            }
            self.reloadFavorites()
        }
    }
}
