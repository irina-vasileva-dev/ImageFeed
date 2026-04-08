import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController {
    private var imagesListView: ImagesListView? { view as? ImagesListView }
    private let imagesListService = ImagesListService.shared
    var photos: [Photo] = []

    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = .current
        formatter.dateFormat = "d MMMM yyyy"
        return formatter
    }()

    override func loadView() {
        view = ImagesListView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let imagesListView else { return }
        let tableView = imagesListView.tableView
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 200
        tableView
            .register(
                ImagesListCell.self,
                forCellReuseIdentifier: ImagesListCell.reuseIdentifier
            )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleImagesListUpdated),
            name: ImagesListService.didChangeNotification,
            object: imagesListService
        )
        
        imagesListService.fetchPhotosNextPage()
    }

    @objc
    private func handleImagesListUpdated() {
        updateTableViewAnimated()
    }

    private func updateTableViewAnimated() {
        guard let tableView = imagesListView?.tableView else { return }

        let oldCount = photos.count
        let newPhotos = imagesListService.photos
        let newCount = newPhotos.count

        photos = newPhotos

        guard newCount > oldCount else {
            tableView.reloadData()
            return
        }

        let indexPaths = (oldCount..<newCount).map {
            IndexPath(row: $0, section: 0)
        }

        tableView.performBatchUpdates {
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        photos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ImagesListCell.reuseIdentifier,
            for: indexPath
        )
        guard let imageListCell = cell as? ImagesListCell else {
            return cell
        }
        configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }
}

extension ImagesListViewController {
    private func configCell(
        for cell: ImagesListCell,
        with indexPath: IndexPath
    ) {
        let photo = photos[indexPath.row]
        cell.delegate = self
        
        cell.imageCell.kf.indicatorType = .activity
        
        let placeholder = UIImage(resource: .imagePlaceholder)
        
        if let url = URL(string: photo.thumbImageURL) {
            cell.imageCell.kf.setImage(
                with: url,
                placeholder: placeholder
            )
        } else {
            cell.imageCell.image = placeholder
        }
        
        if let createdAt = photo.createdAt {
            cell.dateLabel.text = dateFormatter.string(from: createdAt)
        } else {
            cell.dateLabel.text = nil
        }
        
        cell.setIsLiked(photo.isLiked)
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
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photo = photos[indexPath.row]
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = photo.size.width
        guard imageWidth > 0 else { return 0 }

        let scale = imageViewWidth / imageWidth
        return photo.size.height * scale + imageInsets.top + imageInsets.bottom
    }

    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        let singleImageVC = SingleImageViewController()
        let photo = photos[indexPath.row]
        singleImageVC.imageURL = URL(string: photo.largeImageURL)
        singleImageVC.photoId = photo.id
        singleImageVC.isLiked = photo.isLiked
        singleImageVC.modalPresentationStyle = .fullScreen
        present(singleImageVC, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        let lastRowIndex = photos.count - 1
        if indexPath.row == lastRowIndex {
            imagesListService.fetchPhotosNextPage()
        }
    }

}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let tableView = imagesListView?.tableView else { return }
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        
        let photo = photos[indexPath.row]
        UIBlockingProgressHUD.show()
        imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            guard let self else { return }
            switch result {
            case .success:
                guard let updatedIndex = self.imagesListService.photos.firstIndex(where: { $0.id == photo.id }) else {
                    return
                }
                let updatedPhoto = self.imagesListService.photos[updatedIndex]
                if let localIndex = self.photos.firstIndex(where: { $0.id == photo.id }) {
                    self.photos[localIndex] = updatedPhoto
                }
                cell.setIsLiked(updatedPhoto.isLiked)
            case .failure:
                self.showLikeErrorAlert()
            }
        }
    }
}
