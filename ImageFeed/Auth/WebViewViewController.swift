
import UIKit
@preconcurrency import WebKit

// MARK: - protocol WebViewViewControllerDelegate

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}

// MARK: - class WebViewViewController

final class WebViewViewController: UIViewController {
    
    // MARK: - IBOutlet WKWebView
    
    @IBOutlet private var webView: WKWebView!
    
    // MARK: - UIProgressView
    
    @IBOutlet private var progressView: UIProgressView!
    
    // MARK: - delegate: WebViewViewControllerDelegate
    
    weak var delegate: WebViewViewControllerDelegate?
    
    // MARK: - viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.navigationDelegate = self
        
        loadAuthView()
        updateProgress()
    }
    
    // MARK: - didTapBackButton
    
    @IBAction private func didTapBackButton(_ sender: Any?) {
        delegate?.webViewViewControllerDidCancel(self)
    }
    
    // MARK: - KVO
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        webView.addObserver(
            self,
            forKeyPath: #keyPath(WKWebView.estimatedProgress),
            options: .new,
            context: nil)
        updateProgress()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        webView
            .removeObserver(
                self,
                forKeyPath: #keyPath(WKWebView.estimatedProgress),
                context: nil
            )
    }
    
    // MARK: - Обработчик обновлений
    
    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        if keyPath == #keyPath(WKWebView.estimatedProgress) {
            updateProgress()
        } else {
            super.observeValue(
                forKeyPath: keyPath,
                of: object,
                change: change,
                context: context
            )
        }
    }
    
    private func updateProgress() {
        progressView.progress = Float(webView.estimatedProgress)
        progressView.isHidden = fabs(webView.estimatedProgress - 1.0) <= 0.0001
    }
}

// MARK: - Формирование URL

extension WebViewViewController {
    
    private func loadAuthView() {
        guard var urlComponents = URLComponents(string: Constants.unsplashAuthorizeURLString) else {
            return
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: Constants.accessScope)
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
            urlComponents.path == Constants.autorize,
            let items = urlComponents.queryItems,
            let codeItem = items.first(where: { $0.name == "code" })
        {
            print("Code: \(String(describing: codeItem.value))")
            return codeItem.value
        } else {
            return nil
        }
    }
}
