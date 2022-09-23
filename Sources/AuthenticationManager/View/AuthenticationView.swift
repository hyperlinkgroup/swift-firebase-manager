//
//  AuthenticationView.swift
//  
//
//  Created by Anna Münster on 24.08.22.
//

//#if canImport(UIKit)
import Foundation
import UIKit
import AuthenticationServices

public protocol AuthDelegate: AnyObject {
    func authenticationCompleted(error: Error?)
}

open class AuthenticationView: NSObject {
    weak var delegate: AuthDelegate?
    let presentationContext: PresentationContext
    
    public init?(view: UIView? = nil, delegate: AuthDelegate?) {
        guard let window = view?.window ?? UIApplication.keyWindow ?? nil else { return nil }
        
        self.presentationContext = PresentationContext(window: window)
        self.delegate = delegate
    }
    
    public func authenticateBySignInWithApple() {
        let request = AuthenticationManager.editRequest(scopes: [.email])
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = presentationContext
        authorizationController.performRequests()
    }
}

extension AuthenticationView: ASAuthorizationControllerDelegate {
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        AuthenticationManager.handleAuthorizationResult(.success(authorization)) { error in
            self.delegate?.authenticationCompleted(error: error)
        }
    }
    
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        AuthenticationManager.handleAuthorizationResult(.failure(error)) { result in
            self.delegate?.authenticationCompleted(error: result ?? error)
        }
    }
}

//#endif
