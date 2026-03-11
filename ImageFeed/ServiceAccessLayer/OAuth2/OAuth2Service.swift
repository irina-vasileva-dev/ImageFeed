import Foundation

// MARK: - OAuth2Error

enum OAuth2Error: Error {
    case invalidURL
    case invalidHTTPResponse
    case decodingFailed(Error)
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
    private let decoder = JSONDecoder()

    private init() {}

    func fetchOAuthToken(
        _ code: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        guard let request = makeTokenRequest(code: code) else {
            logger.error("Failed to build token request URL")
            completion(.failure(OAuth2Error.invalidURL))
            return
        }

        logger.debug("Request: \(request.url?.absoluteString ?? "nil")")

        let task = URLSession.shared.data(for: request) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let data):
                self.handleTokenResponse(data: data, completion: completion)
            case .failure(let error):
                self.logger.error("Network error: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        task.resume()
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

    private func handleTokenResponse(
        data: Data,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        do {
            let body = try decoder.decode(OAuthTokenResponseBody.self, from: data)
            OAuth2TokenStorage.shared.token = body.accessToken
            logger.debug("Access token received")
            completion(.success(body.accessToken))
        } catch {
            logger.error("Decoding error: \(error.localizedDescription)")
            completion(.failure(OAuth2Error.decodingFailed(error)))
        }
    }
}
