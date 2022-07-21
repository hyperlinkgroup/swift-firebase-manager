//
//  Authentication.swift
//  
//
//  Created by Kevin Waltz on 22.04.22.
//

import AuthenticationServices

extension AuthenticationManager {
    /**
     Handle the Sign in with Apple request by setting a nonce string.
     
     - Parameter request: Request sent to Apple
     - Parameter scopes: Required user data (full name and/or email)
     */
    public static func handleAuthorizationRequest(_ request: ASAuthorizationAppleIDRequest, scopes: [ASAuthorization.Scope] = [.fullName, .email]) {
        let nonce = randomNonceString()
        currentNonce = nonce
        
        request.requestedScopes = scopes
        request.nonce = sha256(nonce)
    }
    
    /**
     Handle the result passed after the Sign in with Apple button was tapped.
     
     - Parameter result: Result passed from Apple
     */
    public static func handleAuthorizationResult(_ result: Result<ASAuthorization, Error>, completion: @escaping (String?, ASAuthorizationAppleIDCredential?, Error?) -> Void) {
        switch result {
        case .success(let authorization):
            let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential
            completion(currentNonce, appleIDCredential, nil)
        case .failure(let error):
            print(error.localizedDescription)
            completion(nil, nil, error)
        }
    }
}
