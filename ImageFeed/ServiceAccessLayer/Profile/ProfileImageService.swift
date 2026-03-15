import Foundation

// MARK: - ProfileImage

struct ProfileImage: Codable {
    let small: String
    let medium: String?
    let large: String?

    private enum CodingKeys: String, CodingKey {
        case small, medium, large
    }

    var bestForAvatar: String { large ?? medium ?? small }
}

// MARK: - UserResult

struct UserResult: Codable {
    let profileImage: ProfileImage

    private enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}

// MARK: - ProfileProtocol

protocol ProfileImageProtocol: AnyObject {
    func fetchProfileImageURL(
        username: String,
        _ completion: @escaping (Result<String, Error>) -> Void)
}

// MARK: - ProfileImageService

final class ProfileImageService: ProfileImageProtocol {
    static let shared = ProfileImageService()
    
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
   
    private let logger = AppLogger.logger(category: "ProfileImage")
    
    private (set) var avatarURL: String?
   
    private var task: URLSessionTask?

    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        task?.cancel()

        guard let token = OAuth2TokenStorage.shared.token else {
            completion(.failure(NSError(domain: "ProfileImageService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Authorization token missing"])))
            return
        }

        guard let request = makeProfileImageRequest(username: username, token: token) else {
            completion(.failure(URLError(.badURL)))
            return
        }

        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            switch result {
            case .success(let userResult):
                guard let self else { return }
                let avatarURL = userResult.profileImage.bestForAvatar
                self.avatarURL = avatarURL
                completion(.success(avatarURL))
                NotificationCenter.default
                    .post(
                        name: ProfileImageService.didChangeNotification,
                        object: self,
                        userInfo: ["URL": avatarURL])
            case .failure(let error):
                self?.logger.error("[fetchProfileImageURL]: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }

        self.task = task
        task.resume()
    }

    // MARK: - Private
    
    private func makeProfileImageRequest(username: String, token: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/users/\(username)") else {
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
