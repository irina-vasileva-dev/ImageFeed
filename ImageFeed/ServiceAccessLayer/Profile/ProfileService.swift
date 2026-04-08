import Foundation

// MARK: - Profile

struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String?
}

// MARK: - ProfileProtocol

protocol ProfileProtocol: AnyObject {
    func fetchProfile(
        _ token: String,
        completion: @escaping (Result<Profile, Error>) -> Void
    )
}

// MARK: - ProfileService

final class ProfileService: ProfileProtocol {
    static let shared = ProfileService()
    
    private init() {}

    private var task: URLSessionTask?
    private let urlSession = URLSession.shared
    private(set) var profile: Profile?
    private let logger = AppLogger.logger(category: "Profile")

    func fetchProfile(
        _ token: String,
        completion: @escaping (Result<Profile, Error>) -> Void
    ) {
        task?.cancel()

        guard let request = makeProfileRequest(token: token) else {
            completion(.failure(URLError(.badURL)))
            return
        }

        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            switch result {
            case .success(let profileResult):
                let name = "\(profileResult.firstName) \(profileResult.lastName)"
                    .trimmingCharacters(in: .whitespaces)
                let profile = Profile(
                    username: profileResult.username,
                    name: name,
                    loginName: "@\(profileResult.username)",
                    bio: profileResult.bio
                )
                self?.profile = profile
                completion(.success(profile))
            case .failure(let error):
                self?.logger.error("[ProfileService fetchProfile]: \(error.localizedDescription)")
                completion(.failure(error))
            }
            self?.task = nil
        }

        self.task = task
        task.resume()
    }

    func resetSession() {
        task?.cancel()
        task = nil
        profile = nil
    }

    // MARK: - Private
    
    private func makeProfileRequest(token: String) -> URLRequest? {
        guard let url = URL(string: URLs.getUsersProfileURL) else {
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        UnsplashAPIHeaders.apply(to: &request, userAccessToken: token)
        return request
    }
}

