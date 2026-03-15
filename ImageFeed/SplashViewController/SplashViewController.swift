import UIKit

final class SplashViewController: UIViewController {

    private let logger = AppLogger.logger(category: "Splash")
    private let oauth2Service: OAuth2ServiceProtocol
    private let tokenStorage: OAuth2TokenStorageProtocol
    private let profileService: ProfileProtocol

    init(
        oauth2Service: OAuth2ServiceProtocol = OAuth2Service.shared,
        tokenStorage: OAuth2TokenStorageProtocol = OAuth2TokenStorage.shared,
        profileService: ProfileProtocol = ProfileService.shared
    ) {
        self.oauth2Service = oauth2Service
        self.tokenStorage = tokenStorage
        self.profileService = profileService
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.oauth2Service = OAuth2Service.shared
        self.tokenStorage = OAuth2TokenStorage.shared
        self.profileService = ProfileService.shared
        super.init(coder: coder)
    }

    // MARK: - Lifecycle

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let token = tokenStorage.token {
            fetchProfile(token: token)
        } else {
            performSegue(
                withIdentifier: SegueIdentifier.showAuthentication,
                sender: nil
            )
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    // MARK: - Private

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
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let tabBarController = storyboard.instantiateViewController(
            withIdentifier: "TabBarViewController"
        ) as? UITabBarController else {
            assertionFailure("Unable to instantiate TabBarViewController")
            return
        }
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }

    private func fetchOAuthToken(_ code: String) {
        oauth2Service.fetchOAuthToken(code) { [weak self] result in
            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismiss()
                guard let self else { return }
                switch result {
                case .success(let token):
                    self.fetchProfile(token: token)
                case .failure(let error):
                    if case OAuth2Error.cancelled = error {
                        return
                    }
                    self.logger.error("Failed to fetch OAuth token")
                }
            }
        }
    }
    
    private func fetchProfile(token: String) {
        UIBlockingProgressHUD.show()
        profileService.fetchProfile(token) { [weak self] result in
            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismiss()
                guard let self else { return }
                switch result {
                case .success:
                    self.switchToTabBarController()
                case .failure(let error):
                    self.logger.error("Failed to fetch profile: \(error.localizedDescription)")
                }
            }
        }
    }
}

// MARK: - Navigation (prepare for segue)

extension SplashViewController {

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifier.showAuthentication {
            guard let navigationController = segue.destination as? UINavigationController,
                  let authVC = navigationController.viewControllers.first as? AuthViewController else {
                assertionFailure(
                    "Failed to prepare for \(SegueIdentifier.showAuthentication)"
                )
                return
            }
            authVC.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

// MARK: - AuthViewControllerDelegate

extension SplashViewController: AuthViewControllerDelegate {

    func authViewController(
        _ vc: AuthViewController,
        didAuthenticateWithCode code: String
    ) {
        dismiss(animated: true) { [weak self] in
            UIBlockingProgressHUD.show()
            self?.fetchOAuthToken(code)
        }
    }
}
