import Foundation

// MARK: - OAuth2TokenStorageProtocol

protocol OAuth2TokenStorageProtocol: AnyObject {
    var token: String? { get set }
}

// MARK: - OAuth2TokenStorage

final class OAuth2TokenStorage: OAuth2TokenStorageProtocol {

    static let shared = OAuth2TokenStorage()

    private enum Keys: String {
        case token
    }

    var token: String? {
        get { userDefaults.string(forKey: Keys.token.rawValue) }
        set { userDefaults.set(newValue, forKey: Keys.token.rawValue) }
    }

    private let userDefaults = UserDefaults.standard

    private init() {}
}
