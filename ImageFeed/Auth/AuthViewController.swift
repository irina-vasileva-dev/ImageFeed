import UIKit

// MARK: - AuthViewControllerDelegate

protocol AuthViewControllerDelegate: AnyObject {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String)
}

// MARK: - AuthViewController

final class AuthViewController: UIViewController {

    weak var delegate: AuthViewControllerDelegate?

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
        delegate?.authViewController(self, didAuthenticateWithCode: code)
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        dismiss(animated: true)
    }
}
