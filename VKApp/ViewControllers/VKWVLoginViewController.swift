//
//  VKWVLoginViewController.swift
//  VKApp
//
//  Created by Alla Shkolnik on 12.02.2022.
//

import KeychainSwift
import UIKit
import WebKit

final class VKWVLoginViewController: UIViewController {
    private let authService = AuthService.shared
    private let notificationCenter = NotificationCenter.default
    var urlComponents: URLComponents {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "oauth.vk.com"
        components.path = "/authorize"
        components.queryItems = [
            URLQueryItem(name: "client_id", value: "8077898"),
            URLQueryItem(name: "display", value: "mobile"),
            URLQueryItem(name: "redirect_uri", value: "https://oauth.vk.com/blank.html"),
            URLQueryItem(name: "scope", value: "336918"),
            URLQueryItem(name: "response_type", value: "token"),
            URLQueryItem(name: "v", value: "5.131")
        ]
        return components
    }
    
    @IBOutlet weak var webView: WKWebView! {
        didSet {
            webView.navigationDelegate = self
        }
    }
    
    // MARK: - Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let url = urlComponents.url else { return }
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    static func logout() {
        AuthService.shared.deleteAuthData()
        
        let dataStore = WKWebsiteDataStore.default()
        dataStore.fetchDataRecords( ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach {
                if $0.displayName.contains("vk") {
                    dataStore.removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), for: [$0]) { }
                }
            }
        }
    }
}

extension VKWVLoginViewController: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationResponse: WKNavigationResponse,
        decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
            guard
                let url = navigationResponse.response.url,
                url.path == "/blank.html",
                let fragment = url.fragment
            else { return decisionHandler(.allow) }
            let parameters = getFragments(fragment)
            
            guard
                let token = parameters["access_token"],
                let userID = parameters["user_id"]
            else { return decisionHandler(.allow) }

            authService.setAuthData(token: token, userID: userID)
            performSegue(withIdentifier: "goToMain", sender: nil)
            decisionHandler(.cancel)
        }
    
    private func getFragments(_ fragment: String) -> [String: String] {
        return fragment
            .components(separatedBy: "&")
            .map { $0.components(separatedBy: "=") }
            .reduce([String: String]()) { partialResult, params in
                var dict = partialResult
                let key = params[0]
                let value = params[1]
                dict[key] = value
                return dict
        }
    }
}

final class AuthService {
    static let shared = AuthService()
    let keychain = KeychainSwift()
    private(set) var userID: String?
    private(set) var token: String?
    
    private init() { }
    
    fileprivate func deleteAuthData() {
        keychain.delete("accessToken")
        keychain.delete("userID")
    }
    
    fileprivate func setAuthData(token: String, userID: String) {
        keychain.set(token, forKey: "accessToken")
        keychain.set(userID, forKey: "userID")
        
        self.userID = userID
        self.token = token
    }
}
