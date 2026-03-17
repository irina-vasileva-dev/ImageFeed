import Foundation

// MARK: - OAuth2Error

enum OAuth2Error: Error {
    case invalidURL
    case invalidHTTPResponse
    case decodingFailed(Error)
    case cancelled
    case noData
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
    private let queue = DispatchQueue(label: "OAuth2ServiceQueue", qos: .userInitiated)
    private var currentCode: String?
    private var currentTask: URLSessionTask?
    private var pendingCompletions: [(Result<String, Error>) -> Void] = []
    private let decoder = JSONDecoder()

    private init() {}

    func fetchOAuthToken(
        _ code: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        queue.async { [weak self] in
            self?.performFetch(code: code, completion: completion)
        }
    }

    private func performFetch(
        code: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        if currentCode == code {
            pendingCompletions.append(completion)
            return
        }

        if let oldCode = currentCode {
            logger.debug("Cancelling previous request for code: \(oldCode)")
            currentTask?.cancel()
            notifyPendingCompletions(with: .failure(OAuth2Error.cancelled))
        }

        guard let request = makeTokenRequest(code: code) else {
            logger.error("Failed to build token request URL")
            completion(.failure(OAuth2Error.invalidURL))
            return
        }

        currentCode = code
        pendingCompletions = [completion]
        logger.debug("Starting token fetch for code: \(code)")

        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            self?.queue.async {
                self?.handleResponse(data: data, response: response, error: error, for: code)
            }
        }

        currentTask = task
        task.resume()
    }

    private func handleResponse(
        data: Data?,
        response: URLResponse?,
        error: Error?,
        for code: String
    ) {
        defer {
            currentCode = nil
            currentTask = nil
        }

        guard currentCode == code else { return }

        if let error = error {
            if (error as NSError).code == NSURLErrorCancelled {
                notifyPendingCompletions(with: .failure(OAuth2Error.cancelled))
            } else {
                logger.error("Network error: \(error.localizedDescription)")
                notifyPendingCompletions(with: .failure(error))
            }
            return
        }

        guard let data else {
            notifyPendingCompletions(with: .failure(OAuth2Error.noData))
            return
        }

        do {
            let tokenResponse = try decoder.decode(OAuthTokenResponseBody.self, from: data)
            OAuth2TokenStorage.shared.token = tokenResponse.accessToken
            logger.debug("Token received successfully")
            notifyPendingCompletions(with: .success(tokenResponse.accessToken))
        } catch {
            logger.error("Decoding error: \(error.localizedDescription)")
            notifyPendingCompletions(with: .failure(OAuth2Error.decodingFailed(error)))
        }
    }

    private func notifyPendingCompletions(with result: Result<String, Error>) {
        let completions = pendingCompletions
        pendingCompletions = []
        DispatchQueue.main.async {
            completions.forEach { $0(result) }
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
