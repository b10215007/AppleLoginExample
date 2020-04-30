//
//  AppleAuthWebViewController.swift
//  AppleLoginExample
//
//  Created by Michael MA on 2020/4/30.
//  Copyright © 2020 馬佳誠. All rights reserved.
//

import UIKit
import WebKit

final class AppleAuthWebViewController: UIViewController {
    
    var code = ""
    lazy var topView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var closeBtn: UIButton = {
        let btn = UIButton()
        btn.setBackgroundImage(UIImage(named: "icon_dismiss"), for: .normal)
        btn.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    @objc
    func closeAction() {
        self.dismiss(animated: true) {
            print(self.code)
            // MARK: - Return code here
        }
    }
    
    lazy var webView: WKWebView = {
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true

        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences

        var webView = WKWebView(frame: .zero, configuration: configuration)
        webView.scrollView.bounces = true
        webView.scrollView.alwaysBounceVertical = true
        webView.navigationDelegate = self
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()
    
    var urlString: String = ""
    var method: String = "GET"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        start()
    }
    
    private func setupUI() {
        self.title = ""
        self.view.backgroundColor = UIColor.white
        self.view.addSubview(topView)
        self.view.addSubview(webView)
        self.topView.addSubview(closeBtn)
        
        NSLayoutConstraint.activate([
            topView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 0),
            topView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0),
            topView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0),
            topView.heightAnchor.constraint(equalToConstant: 42),
            
            closeBtn.centerYAnchor.constraint(equalTo: topView.centerYAnchor, constant: 0),
            closeBtn.rightAnchor.constraint(equalTo: topView.rightAnchor, constant: -12),
            closeBtn.widthAnchor.constraint(equalToConstant: 20),
            closeBtn.heightAnchor.constraint(equalToConstant: 20),
            
            webView.topAnchor.constraint(equalTo: topView.bottomAnchor, constant: 0),
            webView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0),
            webView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0),
            webView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: 0)
        ])
    }
    
    private func start() {
        guard let url = URL(string: urlString) else{return }
        var request = URLRequest(url: url)
        request.httpMethod = method
        webView.load(request)
    }
}

extension AppleAuthWebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // MARK: - Load request finish
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        // MARK: - Load request failed
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let jsCode = "" + "function parseForm(form){" +
            "var values='';" +
            "console.log('RESULT 1='+form.elements);" +
            "for(var i=0 ; i< form.elements.length; i++){" +
            "   values+=form.elements[i].name+'='+form.elements[i].value+'&'" +
            "}" +
            "return [values]" +
            "   }" +
            "for(var i=0 ; i< document.forms.length ; i++){" +
            "   parseForm(document.forms[i]);" +
        "};"
        if let url = navigationAction.request.url, url.lastPathComponent == "redirect" {
            webView.evaluateJavaScript(jsCode) { (result, error) in
                if let res = result as? [String] {
                    self.code = String(res[0].split(separator: "=")[1])
                    self.code = self.code.replacingOccurrences(of: "&", with: "")
                    self.closeAction()
                }
            }
        }
        
        decisionHandler(.allow)
    }

}
