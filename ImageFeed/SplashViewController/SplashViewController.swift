//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Kira on 21.01.2025.
//

import UIKit

final class SplashViewController: UIViewController {
    // MARK: - Vars
    
    private let showAuthenticationScreenSegueIdentifier = "ShowAuthentication"
    //    private let showTableSegueIdentifier = "ShowWebView"
    
    // MARK: - OAuth2Service
    
    private let oauth2Service = OAuth2Service.shared
    
    // MARK: - OAuth2TokenStorage
    
    private let oauth2TokenStorage = OAuth2TokenStorage()
    
    // MARK: - Lifecycle
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if oauth2TokenStorage.token != nil {
            switchToTabBarController()
        } else {
            performSegue(withIdentifier: showAuthenticationScreenSegueIdentifier, sender: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    // MARK: - Private methods
    
    private func switchToTabBarController() {
        
        // Убедитесь, что вы находитесь на главном потоке
            guard Thread.isMainThread else {
                // Если не на главном потоке, использовать dispatch
                DispatchQueue.main.async {
                    self.switchToTabBarController()
                }
                return
            }
        
            guard let window = UIApplication.shared.windows.first else {
                fatalError("Invalid Configuration")
            }
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            guard let tabBarController = storyboard.instantiateViewController(withIdentifier: "TabBarViewController") as? UITabBarController else {
                fatalError("Unable to instantiate TabBarViewController")
            }
            
            window.rootViewController = tabBarController
            window.makeKeyAndVisible()
        }
    }

// MARK: - Prepare for segue

extension SplashViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showAuthenticationScreenSegueIdentifier {
            guard
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers[0] as? AuthViewController
            else { fatalError("Failed to prepare for \(showAuthenticationScreenSegueIdentifier)") }
            
            viewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

// MARK: - AuthViewControllerDelegate

extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        dismiss(animated: true) { [weak self] in
            guard let self else { return }
            self.fetchOAuthToken(code)
        }
    }
    
    private func fetchOAuthToken(_ code: String) {
        oauth2Service.fetchOAuthToken(code) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let accessToken):
                // Сохраняем токен в хранилище
                self.oauth2TokenStorage.token = accessToken
                // Переход к TabBarController
                self.switchToTabBarController()
            case .failure:
                print("Failed to fetch token")
                break
            }
        }
    }
}
