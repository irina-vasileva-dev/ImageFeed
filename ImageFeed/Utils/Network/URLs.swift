import Foundation

/// Заголовки для запросов к `https://api.unsplash.com` (см. документацию Unsplash API).
enum UnsplashAPIHeaders {
    static let acceptVersion = "v1"

    /// `Authorization: Bearer …` + обязательный `Accept-Version`.
    static func apply(to request: inout URLRequest, userAccessToken: String) {
        request.setValue("Bearer \(userAccessToken)", forHTTPHeaderField: "Authorization")
        request.setValue(acceptVersion, forHTTPHeaderField: "Accept-Version")
    }
}

enum URLs {
    static let defaultBaseURL = URL(string: "https://api.unsplash.com")
    
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"

    /// Path used to detect OAuth redirect and extract `code`
    static let authorizeRedirectPath = "/oauth/authorize/native"
    
    static let unsplashOAuthTokenURL = "https://unsplash.com/oauth/token"
    
    static let getUsersProfileURL = "https://api.unsplash.com/me"

    /// Список фотографий (лента), постранично. Параметры: page, per_page
    static let photosURLString = "https://api.unsplash.com/photos"
}
