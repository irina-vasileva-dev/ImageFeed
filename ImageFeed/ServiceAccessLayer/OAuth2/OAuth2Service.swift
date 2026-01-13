//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Kira on 21.01.2025.
//

import Foundation

// MARK: - class OAuth2Service

final class OAuth2Service {
    
    // MARK: - Синглтон
    
    static let shared = OAuth2Service()
    private init() {}
    
    // MARK: - OAuthError
    
    private enum OAuthError: Error {
        case codeError, decodeError
    }
    
    // MARK: - fetchOAuthToken
    
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        
        guard var components = URLComponents(string: "https://unsplash.com/oauth/token") else { return }
        
        components.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        
        if let url = components.url {
            print("URL: \(url)")
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            print("Request: \(request)")
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error: \(error)")
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                    return
                }
                
                // Проверяем статус-код
                if let response = response as? HTTPURLResponse {
                    // Интерполяция должна работать правильно
                    print("HTTP Status Code: \(response.statusCode)")
                    
                    if response.statusCode < 200 || response.statusCode >= 300 {
                        // Печатаем содержимое ответа для дополнительной информации
                        if let data = data, let responseBody = String(data: data, encoding: .utf8) {
                            print("Response Body: \(responseBody)")
                        }
                        DispatchQueue.main.async {
                            completion(.failure(OAuthError.codeError))
                        }
                        return
                    }
                    
                }
                
                guard let data = data else {
                    print("No data returned")
                    DispatchQueue.main.async {
                        completion(.failure(OAuthError.decodeError))
                    }
                    return
                }
                
                
                do {
                    let json = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
                    OAuth2TokenStorage().token = json.accessToken
                    print("Access Token: \(json.accessToken)")
                    DispatchQueue.main.async {
                        completion(.success(json.accessToken))
                    }
                } catch {
                    print("Decoding error: \(error)")
                    DispatchQueue.main.async {
                        completion(.failure(OAuthError.decodeError))
                    }
                }
            }
            task.resume()
        }
    }
}


// MARK: - extension URLSession

extension URLSession {
    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionTask {
        let fulfillCompletionOnTheMainThread: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        let task = dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response, let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if 200 ..< 300 ~= statusCode {
                    fulfillCompletionOnTheMainThread(.success(data))
                } else {
                    fulfillCompletionOnTheMainThread(.failure(NetworkError.httpStatusCode(statusCode)))
                }
            } else if let error = error {
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlRequestError(error)))
            } else {
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlSessionError))
            }
        })
        
        return task
    }
}
