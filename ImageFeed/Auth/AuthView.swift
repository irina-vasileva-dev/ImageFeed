import UIKit

final class AuthView: UIView {

    var onLoginTapped: (() -> Void)?

    private lazy var logoImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(resource: .logoOfUnsplash))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var startButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Войти", for: .normal)
        button.titleLabel?.font = Fonts.ysDisplayBold17 ?? .boldSystemFont(ofSize: 17)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
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
        backgroundColor = UIColor(resource: .ypBlack)
        addSubview(logoImageView)
        addSubview(startButton)
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor),
            logoImageView.topAnchor.constraint(equalTo: topAnchor, constant: 280),
            logoImageView.widthAnchor.constraint(equalToConstant: 60),
            logoImageView.heightAnchor.constraint(equalToConstant: 60),
            startButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            startButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            startButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -124),
            startButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }

    @objc private func loginButtonTapped() {
        onLoginTapped?()
    }
}
