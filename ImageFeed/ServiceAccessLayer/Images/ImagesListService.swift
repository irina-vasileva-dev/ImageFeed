import Foundation

// MARK: - Photo

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
}

// MARK: - ImagesListProtocol

protocol ImagesListProtocol: AnyObject {
    func fetchPhotosNextPage()
    func changeLike(
        photoId: String,
        isLike: Bool,
        _ completion: @escaping (Result<Void, Error>) -> Void
    )
}

// MARK: - ImagesListService

final class ImagesListService: ImagesListProtocol {
    static let shared = ImagesListService()

    private(set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    private var task: URLSessionDataTask?
    private var likeTask: URLSessionDataTask?
    private var rateLimitBlockedUntil: Date?
    private let urlSession = URLSession.shared
    private let perPage = 10

    static let didChangeNotification = Notification.Name(
        rawValue: "ImagesListServiceDidChange"
    )
    private init() {}

    private let logger = AppLogger.logger(category: "ImagesListService")

    func fetchPhotosNextPage() {
        guard task == nil else { return }
        if let blockedUntil = rateLimitBlockedUntil, blockedUntil > Date() {
            logger.error("[ImagesListService.fetchPhotosNextPage]: Rate limit active until \(blockedUntil)")
            return
        }
        guard let token = OAuth2TokenStorage.shared.token else {
            logger.error("[ImagesListService.fetchPhotosNextPage]: нет токена")
            return
        }

        let nextPage = (lastLoadedPage ?? 0) + 1
        guard let request = makePhotosRequest(page: nextPage, token: token) else {
            logger.error("[ImagesListService.fetchPhotosNextPage]: не удалось создать запрос")
            return
        }

        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self else { return }
            self.task = nil
            switch result {
            case .success(let results):
                let newPhotos = results.map { self.photo(from: $0) }
                self.photos.append(contentsOf: newPhotos)
                self.lastLoadedPage = nextPage
                NotificationCenter.default.post(
                    name: Self.didChangeNotification,
                    object: self
                )
            case .failure(let error):
                if self.handleRateLimitIfNeeded(error, source: "fetchPhotosNextPage") {
                    return
                }
                self.logger.error("[ImagesListService.fetchPhotosNextPage]: \(error.localizedDescription)")
            }
        }
        self.task = task
        task.resume()
    }

    func changeLike(
        photoId: String,
        isLike: Bool,
        _ completion: @escaping (Result<Void, Error>) -> Void
    ) {
        likeTask?.cancel()
        if let blockedUntil = rateLimitBlockedUntil, blockedUntil > Date() {
            logger.error("[ImagesListService.changeLike]: Rate limit active until \(blockedUntil)")
            completion(.failure(NetworkError.httpStatusCode(403)))
            return
        }
        guard let token = OAuth2TokenStorage.shared.token else {
            logger.error("[ImagesListService.changeLike]: нет токена")
            completion(.failure(NetworkError.urlSessionError))
            return
        }
        guard let request = makeChangeLikeRequest(photoId: photoId, isLike: isLike, token: token) else {
            logger.error("[ImagesListService.changeLike]: не удалось создать запрос")
            completion(.failure(URLError(.badURL)))
            return
        }

        let task = urlSession.data(for: request) { [weak self] result in
            guard let self else { return }
            self.likeTask = nil
            switch result {
            case .success:
                DispatchQueue.main.async {
                    if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                        let photo = self.photos[index]
                        let newPhoto = Photo(
                            id: photo.id,
                            size: photo.size,
                            createdAt: photo.createdAt,
                            welcomeDescription: photo.welcomeDescription,
                            thumbImageURL: photo.thumbImageURL,
                            largeImageURL: photo.largeImageURL,
                            isLiked: !photo.isLiked
                        )
                        self.photos[index] = newPhoto
                    }
                    completion(.success(()))
                    NotificationCenter.default.post(
                        name: Self.didChangeNotification,
                        object: self
                    )
                }
            case .failure(let error):
                if self.handleRateLimitIfNeeded(error, source: "changeLike") {
                    completion(.failure(error))
                    return
                }
                self.logger.error("[ImagesListService.changeLike]: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }

        likeTask = task
        task.resume()
    }

    func resetSession() {
        task?.cancel()
        task = nil
        likeTask?.cancel()
        likeTask = nil
        photos.removeAll()
        lastLoadedPage = nil
        rateLimitBlockedUntil = nil
    }

    // MARK: - Private

    private func makePhotosRequest(page: Int, token: String) -> URLRequest? {
        guard let base = URL(string: URLs.photosURLString),
              var components = URLComponents(url: base, resolvingAgainstBaseURL: false) else {
            return nil
        }
        components.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: "\(perPage)")
        ]
        guard let url = components.url else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        UnsplashAPIHeaders.apply(to: &request, userAccessToken: token)
        return request
    }

    private func makeChangeLikeRequest(photoId: String, isLike: Bool, token: String) -> URLRequest? {
        guard let base = URL(string: URLs.photosURLString) else {
            return nil
        }
        let url = base
            .appendingPathComponent(photoId)
            .appendingPathComponent("like")
        var request = URLRequest(url: url)
        request.httpMethod = isLike ? HTTPMethod.post.rawValue : HTTPMethod.delete.rawValue
        UnsplashAPIHeaders.apply(to: &request, userAccessToken: token)
        return request
    }

    private static let createdAtFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    private static let createdAtFormatterFallback: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()

    private func photo(from result: PhotoResult) -> Photo {
        let createdAt: Date? = {
            Self.createdAtFormatter.date(from: result.createdAt)
                ?? Self.createdAtFormatterFallback.date(from: result.createdAt)
        }()
        return Photo(
            id: result.id,
            size: CGSize(width: result.width, height: result.height),
            createdAt: createdAt,
            welcomeDescription: result.welcomeDescription,
            thumbImageURL: result.urls.thumb,
            largeImageURL: result.urls.full,
            isLiked: result.likedByUser
        )
    }
    
    /// Unsplash demo rate-limit can be quickly exhausted; pause requests briefly to avoid request storm.
    private func handleRateLimitIfNeeded(_ error: Error, source: String) -> Bool {
        guard case NetworkError.httpStatusCode(403) = error else {
            return false
        }
        let cooldown: TimeInterval = 60
        rateLimitBlockedUntil = Date().addingTimeInterval(cooldown)
        logger.error("[ImagesListService.\(source)]: Rate Limit Exceeded. Requests paused for \(Int(cooldown))s")
        return true
    }
}
