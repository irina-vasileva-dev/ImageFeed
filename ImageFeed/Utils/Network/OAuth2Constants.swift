import Foundation

enum OAuth2Constants {
    static let accessKey = "2dE5bK1NHVVpUpyfYu9Ru3oA4rs-okFfWuO39IN27do"

    static let secretKey = "bW0OrG8SAFFV8nC-Zz81_WhfeG0dCg8_4H0S6Dq-zo0"
    
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"

    static let accessScope = "public+read_user+write_likes"
    
    static let grantType = "authorization_code"
    
    static let responseType = "code"
    
    /// Query parameter name for the authorization code in OAuth redirect
    static let codeQueryParameterName = "code"
}
