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

    private static let didLaunchBeforeKey = "OAuth2TokenStorage.didLaunchBefore"

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

    private init() {
        clearTokenIfFreshInstall()
    }

    private func clearTokenIfFreshInstall() {
        let didLaunchBefore = UserDefaults.standard.bool(
            forKey: Self.didLaunchBeforeKey
        )
        guard !didLaunchBefore else { return }
        keychain.removeObject(forKey: Keys.token.rawValue)
        UserDefaults.standard.set(true, forKey: Self.didLaunchBeforeKey)
    }
}
