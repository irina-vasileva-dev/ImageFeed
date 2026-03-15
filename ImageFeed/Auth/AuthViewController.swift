import UIKit

// MARK: - AuthViewControllerDelegate

protocol AuthViewControllerDelegate: AnyObject {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithToken token: String)
}

// MARK: - AuthViewController

final class AuthViewController: UIViewController {

    weak var delegate: AuthViewControllerDelegate?

    private let oauth2Service: OAuth2ServiceProtocol

    required init?(coder: NSCoder) {
        self.oauth2Service = OAuth2Service.shared
        super.init(coder: coder)
    }

    @IBOutlet private weak var startButton: UIButton!

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureBackButton()
        startButton.titleLabel?.font = Fonts.ysDisplayBold17 ?? .boldSystemFont(ofSize: 17)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifier.showWebView {
            guard let webViewVC = segue.destination as? WebViewViewController else {
                assertionFailure("Failed to prepare for \(SegueIdentifier.showWebView)")
                return
            }
            webViewVC.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }

    // MARK: - Private

    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(
            named: "backward"
        )
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(
            named: "backward"
        )
        navigationItem.backBarButtonItem = UIBarButtonItem(
            title: "",
            style: .plain,
            target: nil,
            action: nil
        )
        navigationItem.backBarButtonItem?.tintColor = UIColor(
            resource: .ypBlack
        )
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
            title: "Что-то пошло не так",
            message: "Не удалось войти в систему",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Ок", style: .default))
        present(alert, animated: true)
    }
}
