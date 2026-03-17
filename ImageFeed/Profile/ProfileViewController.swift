import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {

    private let profileService = ProfileService.shared
    private var profileImageServiceObserver: NSObjectProtocol?

    private var profileView: ProfileView? { view as? ProfileView }

    private enum UIConstants {
        static let profileImageSize: CGFloat = 70
    }

    override func loadView() {
        view = ProfileView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        profileView?.onLogoutTapped = { [weak self] in
            self?.profileView?.removeProfileLabelsFromStack()
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
        updateAvatar()
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
}
