import Foundation

enum URLs {
    static let defaultBaseURL = URL(string: "https://api.unsplash.com")
    
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"

    /// Path used to detect OAuth redirect and extract `code`
    static let authorizeRedirectPath = "/oauth/authorize/native"
    
    static let unsplashOAuthTokenURL = "https://unsplash.com/oauth/token"
    
    static let getUsersProfileURL = "https://api.unsplash.com/me"
    
    
}
