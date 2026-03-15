import Foundation
import SwiftKeychainWrapper

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

    private let keychain = KeychainWrapper.standard

    var token: String? {
        get { keychain.string(forKey: Keys.token.rawValue) }
        set {
            if let newValue {
                keychain.set(newValue, forKey: Keys.token.rawValue)
            } else {
                keychain.removeObject(forKey: Keys.token.rawValue)
            }
        }
    }

    private init() {}
}
