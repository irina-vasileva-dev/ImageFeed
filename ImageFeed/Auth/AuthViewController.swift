import UIKit

// MARK: - AuthViewControllerDelegate

protocol AuthViewControllerDelegate: AnyObject {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithToken token: String)
}

// MARK: - AuthViewController

final class AuthViewController: UIViewController {

    weak var delegate: AuthViewControllerDelegate?

    private let oauth2Service: OAuth2ServiceProtocol

    private var authView: AuthView? { view as? AuthView }

    init(oauth2Service: OAuth2ServiceProtocol = OAuth2Service.shared) {
        self.oauth2Service = oauth2Service
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.oauth2Service = OAuth2Service.shared
        super.init(coder: coder)
    }

    override func loadView() {
        view = AuthView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        authView?.onLoginTapped = { [weak self] in self?.openWebView() }
        configureBackButton()
    }

    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "backward")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "backward")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor(hex: "#1A1B22")
    }

    private func openWebView() {
        let webViewVC = WebViewViewController()
        webViewVC.delegate = self
        webViewVC.modalPresentationStyle = .fullScreen
        present(webViewVC, animated: true)
    }
}

// MARK: - WebViewViewControllerDelegate

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(
        _ vc: WebViewViewController,
        didAuthenticateWithCode code: String
    ) {
        UIBlockingProgressHUD.show()
        oauth2Service.fetchOAuthToken(code) { [weak self] result in
            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismiss()
                guard let self else { return }
                switch result {
                case .success(let token):
                    self.delegate?.authViewController(self, didAuthenticateWithToken: token)
                case .failure(let error):
                    if case OAuth2Error.cancelled = error { return }
                    self.showAuthErrorAlert()
                }
            }
        }
    }

    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        dismiss(animated: true)
    }

    private func showAuthErrorAlert() {
        let alert = UIAlertController(
            title: "Что-то пошло не так(",
            message: "Не удалось войти в систему",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Ок", style: .default))
        present(alert, animated: true)
    }
}
