import UIKit
@preconcurrency import WebKit

// MARK: - WebViewViewControllerDelegate

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}

// MARK: - WebViewViewController

final class WebViewViewController: UIViewController {

    private let logger = AppLogger.logger(category: "WebView")
    @IBOutlet private var webView: WKWebView!
    @IBOutlet private var progressView: UIProgressView!

    private var estimatedProgressObservation: NSKeyValueObservation?

    weak var delegate: WebViewViewControllerDelegate?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        webView.navigationDelegate = self
        loadAuthView()
        updateProgress()
    }

    @IBAction private func didTapBackButton(_ sender: Any?) {
        delegate?.webViewViewControllerDidCancel(self)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        estimatedProgressObservation = webView.observe(
            \.estimatedProgress,
            options: [.new]
        ) { [weak self] _, _ in
            self?.updateProgress()
        }
        updateProgress()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        estimatedProgressObservation?.invalidate()
        estimatedProgressObservation = nil
    }

    private func updateProgress() {
        progressView.progress = Float(webView.estimatedProgress)
        progressView.isHidden = fabs(webView.estimatedProgress - 1.0) <= 0.0001
    }
}

// MARK: - Auth URL

extension WebViewViewController {

    private func loadAuthView() {
        guard var urlComponents = URLComponents(string: URLs.unsplashAuthorizeURLString) else {
            return
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: OAuth2Constants.accessKey),
            URLQueryItem(name: "redirect_uri", value: OAuth2Constants.redirectURI),
            URLQueryItem(name: "response_type", value: OAuth2Constants.responseType),
            URLQueryItem(name: "scope", value: OAuth2Constants.accessScope)
        ]
        
        guard let url = urlComponents.url else {
            return
        }
        
        let request = URLRequest(url: url)
        webView.load(request)
    }
}

// MARK: - WKNavigationDelegate

extension WebViewViewController: WKNavigationDelegate {

    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if let code = code(from: navigationAction) {
            delegate?.webViewViewController(self, didAuthenticateWithCode: code)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
    
    private func code(from navigationAction: WKNavigationAction) -> String? {
        if
            let url = navigationAction.request.url,
            let urlComponents = URLComponents(string: url.absoluteString),
            urlComponents.path == URLs.authorizeRedirectPath,
            let items = urlComponents.queryItems,
            let codeItem = items.first(where: { $0.name == OAuth2Constants.codeQueryParameterName })
        {
            logger.debug("Code: \(String(describing: codeItem.value))")
            return codeItem.value
        } else {
            return nil
        }
    }
}
