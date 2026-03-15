import Foundation

// MARK: - NetworkError

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
}

// MARK: - URLSession + data

extension URLSession {

    private static let logger = AppLogger.logger(category: "URLSession")

    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionDataTask {
        let fulfillOnMain: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async { completion(result) }
        }

        let task = dataTask(with: request) { data, response, error in
            if let error {
                Self.logger.error("[data(for:)]: NetworkError - urlRequestError \(error.localizedDescription)")
                fulfillOnMain(.failure(NetworkError.urlRequestError(error)))
                return
            }
            guard let response = response as? HTTPURLResponse else {
                Self.logger.error("[data(for:)]: NetworkError - urlSessionError (invalid response)")
                fulfillOnMain(.failure(NetworkError.urlSessionError))
                return
            }
            guard (200 ..< 300).contains(response.statusCode) else {
                Self.logger.error("[data(for:)]: NetworkError - код ошибки \(response.statusCode)")
                fulfillOnMain(.failure(NetworkError.httpStatusCode(response.statusCode)))
                return
            }
            guard let data else {
                Self.logger.error("[data(for:)]: NetworkError - urlSessionError (no data)")
                fulfillOnMain(.failure(NetworkError.urlSessionError))
                return
            }
            fulfillOnMain(.success(data))
        }
        return task
    }

     func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionDataTask {
        let decoder = JSONDecoder()
        let task = data(for: request) { (result: Result<Data, Error>) in
            switch result {
            case .success(let data):
                do {
                    let decoded = try decoder.decode(T.self, from: data)
                    completion(.success(decoded))
                } catch {
                    let dataString = String(data: data, encoding: .utf8) ?? ""
                    Self.logger.error("[objectTask(for:)]: DecodingError - \(error.localizedDescription), данные: \(dataString)")
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
        return task
    }
}
