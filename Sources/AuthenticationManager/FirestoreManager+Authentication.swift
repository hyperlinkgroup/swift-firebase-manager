//
//  FirestoreManager+Authentication.swift
//  
//
//  Created by Kevin Waltz on 25.04.22.
//

import AuthenticationServices
import FirebaseFirestoreManager
import FirebaseAuth

// MARK: - Authentication

extension FirestoreManager {
    
    static let auth = Auth.auth()
    /**
     As sign in with Apple does not work on the simulator, we use a static userID for testing purposes.
     */
    public static var userId: String {
        auth.currentUser?.uid ?? ""
    }
    
    public static var userIsLoggedIn: Bool {
        auth.currentUser != nil && AuthenticationManager.authorizationKey != nil
    }
    
    /**
     Sign in with Apple and - on success - sign in with Firebase.
     */
    public static func signInWithApple(credentials: ASAuthorizationAppleIDCredential?, nonce: String?, completion: @escaping (Error?) -> Void) {
        guard let credentials = credentials,
              let token = credentials.identityToken,
              let tokenString = String(data: token, encoding: .utf8),
              let nonce = nonce else {
            
            completion(nil)
            return
        }
        
        let credential = OAuthProvider.credential(withProviderID: AuthenticationManager.providerId, idToken: tokenString, rawNonce: nonce)
        
        auth.signIn(with: credential) { authResult, error in
            if let error = error {
                print(error.localizedDescription)
                completion(error)
                return
            }
            
            AuthenticationManager.authorizationKey = credentials.user
            self.updateUserInfo(with: authResult, credentials: credentials, completion: completion)
        }
    }
    
    /**
     Sign out from Firebase on the device and remove the authorization key for sign in with Apple.
     */
    public static func signOut(completion: @escaping (Error?) -> Void) {
        if let providerId = auth.currentUser?.providerData.first?.providerID,
           providerId == AuthenticationManager.providerId {
            do {
                try auth.signOut()
                AuthenticationManager.removeAuthorizationKey()
                completion(nil)
            } catch let signOutError {
                // TODO: ErrorHandling
                completion(signOutError)
            }
        } else {
            // TODO: ErrorHandling
            completion(nil)
        }
    }
}


// MARK: - User

extension FirestoreManager {
    /**
     Save the received user information from sign in with Apple to Firebase.
     */
    private static func updateUserInfo(with authResult: AuthDataResult?, credentials: ASAuthorizationAppleIDCredential?, completion: @escaping (Error?) -> Void) {
        guard
            let credentials = credentials,
            let email = credentials.email
        else {
            // TODO: ErrorHandling
            completion(nil)
            return
        }
        
        let fullName = credentials.fullName
        let givenName = fullName?.givenName ?? ""
        let familyName = fullName?.familyName ?? ""
        let displayName = givenName + " " + familyName
        
        if let changeRequest = authResult?.user.createProfileChangeRequest() {
            changeRequest.displayName = displayName
            
            changeRequest.commitChanges { error in
                if error != nil {
                    // TODO: save
//                    UserDefaults.save(displayName, forKey: .username)
//                    UserDefaults.save(email, forKey: .usermail)
                    
                    completion(nil)
                    return
                }
                
//                UserRepository.shared.saveUser(name: displayName, email: email, completion: completion)
            }
        } else {
            // TODO: ErrorHandling
            completion(nil)
        }
    }
}
