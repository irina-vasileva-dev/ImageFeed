import UIKit
import ProgressHUD

final class UIBlockingProgressHUD {
    private static var window: UIWindow? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return nil
        }
        return windowScene.windows.first { $0.isKeyWindow } ?? windowScene.windows.first
    }
    
    @MainActor static func show() {
        window?.isUserInteractionEnabled = false
        ProgressHUD.animate()
    }

    @MainActor static func dismiss() {
        window?.isUserInteractionEnabled = true
        ProgressHUD.dismiss()
    }
}
