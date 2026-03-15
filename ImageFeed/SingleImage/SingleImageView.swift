import UIKit

final class SingleImageView: UIView {

    var onBackTapped: (() -> Void)?
    var onShareTapped: (() -> Void)?

    private(set) lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.minimumZoomScale = 0.1
        scroll.maximumZoomScale = 1.25
        scroll.translatesAutoresizingMaskIntoConstraints = false
        return scroll
    }()

    private(set) lazy var imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = true
        return iv
    }()

    private lazy var backButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "nav_bar_backward_btn"), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        return button
    }()

    private(set) lazy var shareButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "sharing_buttton"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var favoritesButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "favorites_button"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
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
        backgroundColor = UIColor(hex: "#1A1B22")
        addSubview(scrollView)
        scrollView.addSubview(imageView)
        addSubview(backButton)
        addSubview(shareButton)
        addSubview(favoritesButton)
        let safe = safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: safe.bottomAnchor, constant: 40),
            backButton.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 8),
            backButton.topAnchor.constraint(equalTo: safe.topAnchor, constant: 11),
            backButton.widthAnchor.constraint(equalToConstant: 24),
            backButton.heightAnchor.constraint(equalToConstant: 24),
            shareButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -68),
            shareButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -51),
            favoritesButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 68),
            favoritesButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -50)
        ])
    }

    @objc private func backButtonTapped() {
        onBackTapped?()
    }

    @objc private func shareButtonTapped() {
        onShareTapped?()
    }

    func setImage(_ image: UIImage?) {
        imageView.image = image
        if image != nil {
            setNeedsLayout()
            layoutIfNeeded()
            updateImageLayout()
        }
    }

    func updateImageLayout() {
        guard let image = imageView.image else { return }
        let scrollViewSize = scrollView.bounds.size
        let imageSize = image.size
        let widthRatio = scrollViewSize.width / imageSize.width
        let heightRatio = scrollViewSize.height / imageSize.height
        let scale = max(widthRatio, heightRatio)
        let scaledWidth = imageSize.width * scale
        let scaledHeight = imageSize.height * scale
        imageView.frame = CGRect(x: 0, y: 0, width: scaledWidth, height: scaledHeight)
        scrollView.contentSize = imageView.frame.size
        scrollView.zoomScale = 1.0
        centerImageInScrollView()
    }

    func centerImageInScrollView() {
        let scrollViewSize = scrollView.bounds.size
        let contentSize = scrollView.contentSize
        let horizontalInset = max((scrollViewSize.width - contentSize.width) * 0.5, 0)
        let verticalInset = max((scrollViewSize.height - contentSize.height) * 0.5, 0)
        scrollView.contentInset = UIEdgeInsets(
            top: verticalInset,
            left: horizontalInset,
            bottom: verticalInset,
            right: horizontalInset
        )
    }
}
