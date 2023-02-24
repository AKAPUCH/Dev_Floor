//
//  WebviewPost.swift
//  Dev_Floor
//
//  Created by 최우태 on 2023/02/21.
//

import UIKit
import WebKit
class WebviewPost: UIViewController {
    
    let webView = WKWebView()
    
    var blogPostURL : URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func loadView() {
        getURL()
        self.view = webView
        
    }
    
    
    
    func getURL() {
        guard let blogPostURL = blogPostURL else {return}
        let request = URLRequest(url: blogPostURL)
        webView.load(request)
        webView.sizeToFit()
    }
    
//    func getURL() {
//        guard let blogPostURL = blogPostURL else {return}
//        let task = URLSession.shared.dataTask(with: blogPostURL) { [weak self] (data, response, error) in
//            guard let self = self else { return }
//            if let error = error {
//                print("Error loading URL: \(error.localizedDescription)")
//                return
//            }
//            if let data = data, let htmlString = String(data: data, encoding: .utf8) {
//                DispatchQueue.main.async { [weak self] in
//                    guard let self = self else { return }
//                    self.webView.loadHTMLString(htmlString, baseURL: blogPostURL)
//                    self.webView.sizeToFit()
//                }
//            }
//        }
//        task.resume()
//    }
    
    
}

//네트워크 상태 표시는 ios13.0 이후부터 할 필요가 없어 deprecated
//extension WebviewPost : UIWebViewDelegate {
//    func webViewDidFinishLoad(_ webView: UIWebView) {
//        UIApplication.shared.isNetworkActivityIndicatorVisible = false
//    }
//}
