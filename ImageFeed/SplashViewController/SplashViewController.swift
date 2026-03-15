import UIKit

final class SplashViewController: UIViewController {

    private let logger = AppLogger.logger(category: "Splash")
    private let tokenStorage: OAuth2TokenStorageProtocol
    private let profileService: ProfileProtocol

    init(
        tokenStorage: OAuth2TokenStorageProtocol = OAuth2TokenStorage.shared,
        profileService: ProfileProtocol = ProfileService.shared
    ) {
        self.tokenStorage = tokenStorage
        self.profileService = profileService
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.tokenStorage = OAuth2TokenStorage.shared
        self.profileService = ProfileService.shared
        super.init(coder: coder)
    }

    override func loadView() {
        view = SplashView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let token = tokenStorage.token {
            fetchProfile(token: token)
        } else {
            showAuthViewController()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    private func switchToTabBarController() {
        guard Thread.isMainThread else {
            DispatchQueue.main.async { self.switchToTabBarController() }
            return
        }
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        let tabBarController = TabBarController()
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }

    private func showAuthViewController() {
        let authVC = AuthViewController()
        authVC.delegate = self
        authVC.modalPresentationStyle = .fullScreen
        present(authVC, animated: true)
    }

    private func fetchProfile(token: String) {
        UIBlockingProgressHUD.show()
        profileService.fetchProfile(token) { [weak self] result in
            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismiss()
                guard let self else { return }
                switch result {
                case .success:
                    if let username = ProfileService.shared.profile?.username {
                        ProfileImageService.shared.fetchProfileImageURL(username: username) { _ in }
                    }
                    self.switchToTabBarController()
                case .failure(let error):
                    self.logger.error("Failed to fetch profile: \(error.localizedDescription)")
                }
            }
        }
    }
}

// MARK: - AuthViewControllerDelegate

extension SplashViewController: AuthViewControllerDelegate {

    func authViewController(
        _ vc: AuthViewController,
        didAuthenticateWithToken token: String
    ) {
        dismiss(animated: true) { [weak self] in
            self?.fetchProfile(token: token)
        }
    }
}
