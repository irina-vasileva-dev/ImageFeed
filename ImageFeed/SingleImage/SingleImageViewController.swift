import UIKit

final class SingleImageViewController: UIViewController {

    var image: UIImage? {
        didSet {
            guard isViewLoaded else { return }
            singleImageView?.setImage(image)
        }
    }

    private var singleImageView: SingleImageView? { view as? SingleImageView }

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
        if let image {
            singleImageView.setImage(image)
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
