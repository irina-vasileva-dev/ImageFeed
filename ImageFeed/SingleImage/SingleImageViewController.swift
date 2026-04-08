import UIKit
import ProgressHUD

final class SingleImageViewController: UIViewController {
    private let imagesListService = ImagesListService.shared

    var image: UIImage? {
        didSet {
            guard isViewLoaded else { return }
            singleImageView?.setImage(image)
        }
    }
    
    var imageURL: URL?
    var photoId: String?
    var isLiked: Bool = false {
        didSet {
            guard isViewLoaded else { return }
            singleImageView?.setIsLiked(isLiked)
        }
    }

    private var singleImageView: SingleImageView? { view as? SingleImageView }
    private var imageTask: URLSessionDataTask?

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func loadView() {
        view = SingleImageView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let singleImageView else { return }
        singleImageView.scrollView.delegate = self
        singleImageView.onBackTapped = { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
        singleImageView.onShareTapped = { [weak self] in
            self?.shareImage()
        }
        singleImageView.onFavoritesTapped = { [weak self] in
            self?.toggleLike()
        }
        singleImageView.setIsLiked(isLiked)
        if let image {
            singleImageView.setImage(image)
        } else if let imageURL {
            loadImage(from: imageURL)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if image != nil {
            singleImageView?.updateImageLayout()
        }
    }

    private func shareImage() {
        guard let image else { return }
        singleImageView?.shareButton.isEnabled = false
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let compressedImage = self?.compressImageIfNeeded(image) ?? image
            DispatchQueue.main.async {
                self?.singleImageView?.shareButton.isEnabled = true
                let activityViewController = UIActivityViewController(
                    activityItems: [compressedImage],
                    applicationActivities: nil
                )
                self?.present(activityViewController, animated: true, completion: nil)
            }
        }
    }
    
    private func loadImage(from url: URL) {
        ProgressHUD.animate()
        imageTask?.cancel()
        
        imageTask = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            DispatchQueue.main.async {
                guard let self else { return }
                ProgressHUD.dismiss()
                
                if let error {
                    self.showImageLoadingErrorAlert(message: error.localizedDescription)
                    return
                }
                
                guard let data, let loadedImage = UIImage(data: data) else {
                    self.showImageLoadingErrorAlert(message: "Не удалось загрузить изображение.")
                    return
                }
                
                self.image = loadedImage
                self.singleImageView?.setImage(loadedImage)
            }
        }
        imageTask?.resume()
    }
    
    private func showImageLoadingErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "Ошибка загрузки",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Назад", style: .cancel) { [weak self] _ in
            self?.dismiss(animated: true)
        })
        present(alert, animated: true)
    }
    
    private func toggleLike() {
        guard let photoId else { return }
        UIBlockingProgressHUD.show()
        imagesListService.changeLike(photoId: photoId, isLike: !isLiked) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            guard let self else { return }
            switch result {
            case .success:
                if let index = self.imagesListService.photos.firstIndex(where: { $0.id == photoId }) {
                    self.isLiked = self.imagesListService.photos[index].isLiked
                } else {
                    self.isLiked.toggle()
                }
            case .failure:
                self.showLikeErrorAlert()
            }
        }
    }
    
    private func showLikeErrorAlert() {
        let alert = UIAlertController(
            title: "Что-то пошло не так",
            message: "Не удалось изменить лайк. Попробуйте позже.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Ок", style: .default))
        present(alert, animated: true)
    }

    private func compressImageIfNeeded(_ image: UIImage) -> UIImage {
        let maxFileSize: Int = 10 * 1024 * 1024
        guard let imageData = image.jpegData(compressionQuality: 1.0),
              imageData.count > maxFileSize else {
            return image
        }
        var compression: CGFloat = 0.9
        while let compressedData = image.jpegData(compressionQuality: compression),
              compressedData.count > maxFileSize && compression > 0.1 {
            compression -= 0.1
        }
        if let finalData = image.jpegData(compressionQuality: compression),
           let compressedImage = UIImage(data: finalData) {
            return compressedImage
        }
        return image
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        singleImageView?.imageView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        singleImageView?.centerImageInScrollView()
    }
}
