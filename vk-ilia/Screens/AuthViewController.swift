//
//  ViewController.swift
//  vk-ilia
//
//  Created by Artur Igberdin on 06.04.2022.
//

import UIKit
import WebKit

class AuthViewController: UIViewController, WKNavigationDelegate {

    //Глобальная область видимости контроллера
    
    //VC -> WebView (держат друг друга)
    @IBOutlet weak var webView: WKWebView! {
        didSet {
            //WebView -> VC
            webView.navigationDelegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Внутреннаяя область видимости функции
        authorizeToAPI()
    }
 /*
https
  ://oauth.vk.com
  /authorize
  
  ?client_id=1
  &display=page
  &redirect_uri=http://example.com/callback
  &scope=friends
  &response_type=token
  &v=5.131
  &state=123456
  */
    func authorizeToAPI() {
        
        //Конструктор URL
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "oauth.vk.com"
        urlComponents.path = "/authorize"
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: "7822904"),
            URLQueryItem(name: "display", value: "mobile"),
            URLQueryItem(name: "redirect_uri", value: "https://oauth.vk.com/blank.html"),
            URLQueryItem(name: "scope", value: "271366"),
            URLQueryItem(name: "response_type", value: "token"),
            URLQueryItem(name: "v", value: "5.131"),
            URLQueryItem(name: "revoke", value: "1"),
        ]
        
        //Запрос
        let request = URLRequest(url: urlComponents.url!)
        
        //Браузер отпрвляет запрос
        webView.load(request)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        
        guard let url = navigationResponse.response.url, url.path == "/blank.html" else {
            print(navigationResponse.response.url)
            
            decisionHandler(.allow)
            return
        }
        
        print(navigationResponse.response.url)
        
        /*
         Optional(https://oauth.vk.com/blank.html#access_token=173f86190c1071a2816e3be4658775f372e4fbf1b2a4c3a88a6a29adad0336e2b130a9aaaf3944ca1609d&expires_in=86400&user_id=223761261)
         
         fragment - означает кусок url после #
         access_token=173f86190c1071a2816e3be4658775f372e4fbf1b2a4c3a88a6a29adad0336e2b130a9aaaf3944ca1609d&expires_in=86400&user_id=223761261)
         
         разбили на &
         access_token=173f86190c1071a2816e3be4658775f372e4fbf1b2a4c3a88a6a29adad0336e2b130a9aaaf3944ca1609d
         expires_in=86400
         user_id=223761261
         
         разбили на =
         [access_token,
         173f86190c1071a2816e3be4658775f372e4fbf1b2a4c3a88a6a29adad0336e2b130a9aaaf3944ca1609d
         expires_in,
         86400,
         user_id,
         223761261]
         
         */
        
        print(url.fragment)
        
        
        
        let paramsDictionary = url
            .fragment?
            .components(separatedBy: "&")
            .map { $0.components(separatedBy: "=") }
            .reduce([String: String]()) { partialResult, param in
                var dictionary = partialResult
                let key = param[0]
                let value = param[1]
                dictionary[key] = value
                return dictionary
            }
        
        print(paramsDictionary)
        
        guard let token = paramsDictionary?["access_token"],
              let userId = paramsDictionary?["user_id"],
              let expiresIn = paramsDictionary?["expires_in"] else { return }
            
        
        User.shared.token = token
        User.shared.expiresIn = expiresIn
        User.shared.userId = userId
        
        performSegue(withIdentifier: "showFriendsSegue", sender: nil)
        
        decisionHandler(.cancel)
    }

}

