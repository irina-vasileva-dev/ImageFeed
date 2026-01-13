//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Kira on 21.01.2025.
//

import Foundation

final class OAuth2TokenStorage {
    private enum Keys: String {
        case token
    }
    var token: String? {
        get {
            userDefaults.string(forKey: Keys.token.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.token.rawValue)
        }
    }
    private let userDefaults = UserDefaults.standard
}
