import Foundation

// MARK: - OAuth2Error

enum OAuth2Error: Error {
    case invalidURL
    case invalidHTTPResponse
    case decodingFailed(Error)
    case cancelled
}

// MARK: - OAuth2ServiceProtocol

protocol OAuth2ServiceProtocol: AnyObject {
    func fetchOAuthToken(
        _ code: String,
        completion: @escaping (Result<String, Error>) -> Void
    )
}

// MARK: - OAuth2Service

final class OAuth2Service: OAuth2ServiceProtocol {

    static let shared = OAuth2Service()

    private let logger = AppLogger.logger(category: "OAuth2")
    private let lock = NSLock()
    private var currentCode: String?
    private var currentTask: URLSessionDataTask?
    private var pendingCompletions: [(Result<String, Error>) -> Void] = []

    private init() {}

    func fetchOAuthToken(
        _ code: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        lock.lock()

        if let existingCode = currentCode {
            if existingCode == code {
                pendingCompletions.append(completion)
                lock.unlock()
                return
            }
            currentTask?.cancel()
            let previousCompletions = pendingCompletions
            currentCode = nil
            currentTask = nil
            pendingCompletions = []
            lock.unlock()
            previousCompletions.forEach { $0(.failure(OAuth2Error.cancelled)) }
            lock.lock()
        }

        guard let request = makeTokenRequest(code: code) else {
            lock.unlock()
            logger.error("Failed to build token request URL")
            completion(.failure(OAuth2Error.invalidURL))
            return
        }

        logger.debug("Request: \(request.url?.absoluteString ?? "nil")")
        currentCode = code
        pendingCompletions = [completion]
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            self?.handleTokenTaskCompleted(code: code, result: result)
        }
        currentTask = task
        lock.unlock()
        task.resume()
    }

    private func handleTokenTaskCompleted(code: String, result: Result<OAuthTokenResponseBody, Error>) {
        lock.lock()
        guard currentCode == code else {
            lock.unlock()
            return
        }
        let completions = pendingCompletions
        currentCode = nil
        currentTask = nil
        pendingCompletions = []
        lock.unlock()

        switch result {
        case .success(let body):
            OAuth2TokenStorage.shared.token = body.accessToken
            logger.debug("Access token received")
            completions.forEach { $0(.success(body.accessToken)) }
        case .failure(let error):
            if (error as NSError).code == NSURLErrorCancelled {
                completions.forEach { $0(.failure(OAuth2Error.cancelled)) }
            } else {
                logger.error("[fetchOAuthToken]: \(error.localizedDescription)")
                completions.forEach { $0(.failure(error)) }
            }
        }
    }

    // MARK: - Private

    private func makeTokenRequest(code: String) -> URLRequest? {
        guard var components = URLComponents(string: URLs.unsplashOAuthTokenURL) else {
            return nil
        }
        components.queryItems = [
            URLQueryItem(name: "client_id", value: OAuth2Constants.accessKey),
            URLQueryItem(name: "client_secret", value: OAuth2Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: OAuth2Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: OAuth2Constants.grantType)
        ]
        guard let url = components.url else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        return request
    }

}
