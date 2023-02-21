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
        self.view = webView
    }
    
    
    
    func getURL() {
        guard let blogPostURL = blogPostURL else {return}
        let request = URLRequest(url: blogPostURL)
        webView.load(request)
        webView.sizeToFit()
    }
    
    
}

//네트워크 상태 표시는 ios13.0 이후부터 할 필요가 없어 deprecated
//extension WebviewPost : UIWebViewDelegate {
//    func webViewDidFinishLoad(_ webView: UIWebView) {
//        UIApplication.shared.isNetworkActivityIndicatorVisible = false
//    }
//}
