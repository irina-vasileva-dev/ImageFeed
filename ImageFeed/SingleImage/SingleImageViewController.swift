import UIKit

final class SingleImageViewController: UIViewController {
    var image: UIImage? {
        didSet {
            guard isViewLoaded, let image else { return }
            imageView.image = image
            setupImageLayout()
        }
    }
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        
        imageView.translatesAutoresizingMaskIntoConstraints = true
        
        imageView.contentMode = .scaleToFill
        
        guard let image else { return }
        imageView.image = image
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard image != nil else { return }
        setupImageLayout()
    }
    
    @IBAction private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func didTapShareButton(_ sender: UIButton) {
        guard let image = image else { return }
        
        let compressedImage = compressImageIfNeeded(image)
        
        let activityViewController = UIActivityViewController(
            activityItems: [compressedImage],
            applicationActivities: nil
        )
      
        present(activityViewController, animated: true, completion: nil)
    }
    
    private func setupImageLayout() {
        guard let image = image else { return }
        
        let scrollViewSize = scrollView.bounds.size
        let imageSize = image.size
        
        let widthRatio = scrollViewSize.width / imageSize.width
        let heightRatio = scrollViewSize.height / imageSize.height
        let scale = max(widthRatio, heightRatio)
        
        let scaledWidth = imageSize.width * scale
        let scaledHeight = imageSize.height * scale
        
        imageView.frame = CGRect(
            x: 0,
            y: 0,
            width: scaledWidth,
            height: scaledHeight
        )
        
        scrollView.contentSize = imageView.frame.size
      
        scrollView.zoomScale = 1.0
        
        centerImage()
    }
    
    private func centerImage() {
        let scrollViewSize = scrollView.bounds.size
        let contentSize = scrollView.contentSize
        
        let horizontalInset = max(
            (scrollViewSize.width - contentSize.width) * 0.5,
            0
        )
        let verticalInset = max(
            (scrollViewSize.height - contentSize.height) * 0.5,
            0
        )
        
        scrollView.contentInset = UIEdgeInsets(
            top: verticalInset,
            left: horizontalInset,
            bottom: verticalInset,
            right: horizontalInset
        )
    }
    
    private func compressImageIfNeeded(_ image: UIImage) -> UIImage {
        let maxFileSize: Int = 10 * 1024 * 1024
        
        guard let imageData = image.jpegData(compressionQuality: 1.0),
              imageData.count > maxFileSize else {
            return image
        }
        
        var compression: CGFloat = 0.9
        while let compressedData = image.jpegData(
            compressionQuality: compression
        ),
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
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerImage()
    }
}
