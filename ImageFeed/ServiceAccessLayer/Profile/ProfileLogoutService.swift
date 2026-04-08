import Foundation
import WebKit

final class ProfileLogoutService {
    static let shared = ProfileLogoutService() 
  
    private init() { }

    func logout() {
        OAuth2TokenStorage.shared.token = nil
        ProfileService.shared.resetSession()
        ImagesListService.shared.resetSession()
        ProfileImageService.shared.resetSession()
        cleanCookies()
    }

    private func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore
            .default()
            .fetchDataRecords(
                ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()
            ) { records in
                records.forEach { record in
                    WKWebsiteDataStore
                        .default()
                        .removeData(
                            ofTypes: record.dataTypes,
                            for: [record],
                            completionHandler: {
                            })
                }
            }
    }
}
    
