//
//  Authentication.swift
//  
//
//  Created by Kevin Waltz on 22.04.22.
//

import AuthenticationServices
import FirebaseAuth
import FirebaseFirestoreManager

extension AuthenticationManager {
    /**
     Add to the Sign in with Apple request a nonce string.
     
     - Parameter request: Request sent to Apple
     - Parameter scopes: Required user data (full name and/or email)
     */
    public static func editRequest(_ request: ASAuthorizationAppleIDRequest? = nil, scopes: [ASAuthorization.Scope] = [.fullName, .email]) -> ASAuthorizationAppleIDRequest {
        let request = request ?? ASAuthorizationAppleIDProvider().createRequest()
        // needs to be generated on each request
        currentNonce = Nonce()
        
        request.requestedScopes = scopes
        request.nonce = currentNonce.sha256()
        
        return request
    }
    
    /**
     Handle the result passed after the Sign in with Apple button was tapped.
     
     - Parameter result: Result passed from Apple
     */
    public static func handleAuthorizationResult(_ authResult: Result<ASAuthorization, Error>, completion: @escaping (Error?) -> Void) {
        
        checkAuthorizationResult(authResult) { result in
            switch result {
            case .success(let credential):
                updateUserInfo(credential: credential, completion: completion)
            case .failure(let error):
                self.handleError(error, completion: completion)
            }
        }
    }
    
    /**
     Checks that the result contains the requested AppleID-Credential and uses it for Authentication
     */
    private static func checkAuthorizationResult(_ result: Result<ASAuthorization, Error>, completion: @escaping (Result<ASAuthorizationAppleIDCredential, Error>) -> Void) {
        
        switch result {
        case .success(let authorization):
            guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential
            else {
                completion(.failure(AuthorizationError.credential(description: "Did not receive an AppleIDCredential, but \(type(of: authorization.credential))")))
                return
            }
            authenticateWithCredential(credential: appleIDCredential, completion: completion)
        case .failure(let error):
            completion(.failure(error))
        }
    }
    
    private static func authenticateWithCredential(credential appleCredential: ASAuthorizationAppleIDCredential, completion: @escaping (Result<ASAuthorizationAppleIDCredential, Error>) -> Void) {
        self.authorizationKey = appleCredential.user
        
        guard let identityToken = appleCredential.identityToken,
              let stringifiedToken = String(data: identityToken, encoding: .utf8)
        else {
            completion(.failure(AuthorizationError.credential(description: "Missing Identity Token")))
            return
        }
        
        // create credential for firebase, based on apple-credential
        let credential = OAuthProvider.credential(withProviderID: providerId,
                                                  idToken: stringifiedToken,
                                                  rawNonce: currentNonce.value)
        
        authenticate(credential: credential) { result in
            completion(result.map {_ in appleCredential})
        }
    }

    /**
     Depending on current authentication state, the user is signed in, refreshed or linked
     */
    static func authenticate(credential: AuthCredential, completion: @escaping (Result<Bool, Error>) -> Void) {
        
        if let currentUser {
            if !userIsAuthenticated {
                // anonymous account is linked to new created one
                currentUser.link(with: credential, completion: handleResult)
            } else {
                currentUser.reauthenticate(with: credential, completion: handleResult)
            }
        } else {
            auth.signIn(with: credential, completion: handleResult)
        }
        
        // inner function since results from different auth-functions are same
        func handleResult(authResult: AuthDataResult?, error: Error?) {
            if authResult?.user != nil {
                completion(.success(true))
                return
            }
            completion(.failure(error ?? AuthenticationError.unknown))
        }
    }
    
    /**
     Save the received user information from Sign in with Apple to Firebase.
     If the user authenticated on this device already, the requested infos are not in the scope, so we need to take care, that already existing values are not overwritten by empty values
     */
    static func updateUserInfo(credential: ASAuthorizationAppleIDCredential, completion: @escaping (Error?) -> Void) {
        
        guard let repository = self.configuration.userRepository else {
            completion(nil)
            return
        }
        repository.updateUserInfo(email: credential.email, name: credential.displayName, completion: completion)
    }
}
