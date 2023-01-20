//
//  AuthenticationView.swift
//  
//
//  Created by Anna Münster on 24.08.22.
//

#if canImport(UIKit)
import UIKit
import AuthenticationServices

public protocol SignInWithAppleAuthenticationDelegate: AnyObject {
    func signInWithAppleCompleted(error: Error?)
}

open class SignInWithAppleAuthenticationView: NSObject {
    weak var delegate: SignInWithAppleAuthenticationDelegate?
    let presentationContext: PresentationContext
    
    public init?(view: UIView? = nil, delegate: SignInWithAppleAuthenticationDelegate?) {
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

extension SignInWithAppleAuthenticationView: ASAuthorizationControllerDelegate {
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        AuthenticationManager.handleAuthorizationResult(.success(authorization)) { error in
            self.delegate?.signInWithAppleCompleted(error: error)
        }
    }
    
    public func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        AuthenticationManager.handleAuthorizationResult(.failure(error)) { result in
            self.delegate?.signInWithAppleCompleted(error: result ?? error)
        }
    }
}
#endif
