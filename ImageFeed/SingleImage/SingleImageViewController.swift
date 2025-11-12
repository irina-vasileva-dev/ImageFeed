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
    
    @IBAction private func didTapShareButton() {
        guard let image = image else { return }
        let activityItems: [Any] = [image]
        let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
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

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerImage()
    }
}
