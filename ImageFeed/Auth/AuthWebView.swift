import UIKit
@preconcurrency import WebKit

final class AuthWebView: UIView {

    var onBackTapped: (() -> Void)?

    private(set) lazy var webView: WKWebView = {
        let webView = WKWebView(frame: .zero)
        webView.backgroundColor = .white
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()

    private(set) lazy var progressView: UIProgressView = {
        let progress = UIProgressView(progressViewStyle: .default)
        progress.progress = 0.5
        progress.tintColor = .black
        progress.translatesAutoresizingMaskIntoConstraints = false
        return progress
    }()

    private lazy var backButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "backward"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        return button
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
        backgroundColor = .white
        addSubview(webView)
        addSubview(progressView)
        addSubview(backButton)
        let safe = safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: safe.leadingAnchor),
            backButton.topAnchor.constraint(equalTo: safe.topAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 24),
            backButton.heightAnchor.constraint(equalToConstant: 24),
            progressView.leadingAnchor.constraint(equalTo: safe.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: safe.trailingAnchor),
            progressView.topAnchor.constraint(equalTo: safe.topAnchor, constant: 40),
            webView.topAnchor.constraint(equalTo: safe.topAnchor),
            webView.leadingAnchor.constraint(equalTo: leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    @objc private func backButtonTapped() {
        onBackTapped?()
    }

    func updateProgress(_ progress: Float, isHidden: Bool) {
        progressView.progress = progress
        progressView.isHidden = isHidden
    }
}
