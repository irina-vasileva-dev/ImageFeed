import Foundation

// MARK: - NetworkError

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
}

// MARK: - URLSession + data

extension URLSession {

    /// Performs a data task and delivers the result on the main queue.
    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionDataTask {
        let fulfillOnMain: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async { completion(result) }
        }

        let task = dataTask(with: request) { data, response, error in
            if let error {
                fulfillOnMain(.failure(NetworkError.urlRequestError(error)))
                return
            }
            guard let response = response as? HTTPURLResponse else {
                fulfillOnMain(.failure(NetworkError.urlSessionError))
                return
            }
            guard (200 ..< 300).contains(response.statusCode) else {
                fulfillOnMain(.failure(NetworkError.httpStatusCode(response.statusCode)))
                return
            }
            guard let data else {
                fulfillOnMain(.failure(NetworkError.urlSessionError))
                return
            }
            fulfillOnMain(.success(data))
        }
        return task
    }
}
