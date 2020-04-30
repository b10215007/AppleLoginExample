//
//  AppleLoginProtocol.swift
//  AppleLoginExample
//
//  Created by Michael MA on 2020/4/30.
//  Copyright © 2020 馬佳誠. All rights reserved.
//

import UIKit
import AuthenticationServices

protocol AppleLoginProtocol {
    func appleLogin()
    func appleLoginFailed()
}
extension AppleLoginProtocol where Self: UIViewController {
    func presentASAuthorization() {
        if #available(iOS 13.0, *) {
            let idProviderRequest = ASAuthorizationAppleIDProvider().createRequest()
            idProviderRequest.requestedScopes = [.email, .fullName]
            
            let vc = ASAuthorizationController(authorizationRequests: [idProviderRequest])
            vc.delegate = self
            vc.presentationContextProvider = self
            vc.performRequests()
        } else {
            let client_id = "" // MARK: - Apply in Apple Developer website
            let redirect_uri = "https://" // MARK: - Apply in Apple Developer website, should have http prefix
            var authorizedString = "https://appleid.apple.com/auth/authorize?"
            authorizedString.append("client_id=\(client_id)&")
            authorizedString.append("redirect_uri=\(redirect_uri)&")
            authorizedString.append("response_type=code&")
            authorizedString.append("response_mode=form_post&") // MARK: - If request more infomation like email name, should change response_mode to form_post
            authorizedString.append("scope=name%20email")
            
            let vc = AppleAuthWebViewController()
            vc.urlString = authorizedString
            self.present(vc, animated: true, completion: nil)
        }
    }
}
extension UIViewController: AppleLoginProtocol {
    func appleLogin() {
        // MARK: - Use custom Apple Login Here, can by pass access Token, id Token, anything you like
    }
    
    func appleLoginFailed() {
        // MARK: - Use custom Apple Login Failed
    }
}
extension UIViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            return
        }

        var identityTokenString = ""
        // Call API Here
        if let authorizationCode = credential.authorizationCode {
            print("code: \(String(data: authorizationCode, encoding: .utf8))")
        }
        if let identityToken = credential.identityToken {
            identityTokenString = String(data: identityToken, encoding: .utf8) ?? ""
            print("identity token: \(identityTokenString)")
        }
        print("user apple id: \(credential.user)")
        print("user full name: \(credential.fullName)") // MARK: - Add in idProvider scope
        print("user email: \(credential.email)") // MARK: - Add in idProvider scope
        
        appleLogin()
    }
    
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        appleLoginFailed()
    }
    
    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        self.view.window!
    }
}
