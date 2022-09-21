//
//  AuthenticationManager.swift
//  
//
//  Created by Kevin Waltz on 22.04.22.
//

import FirebaseAuth

open class AuthenticationManager: NSObject {
    static let auth = Auth.auth()
    static let providerId = "apple.com"
    
    static var authView: AuthenticationView?
    
    enum UserDefaultsKeys: String {
        case authorizationIdKey, userNameKey, emailKey
    }
    
    static var currentNonce = Nonce()
    
    
    public static var currentUser: User? {
        auth.currentUser
    }
    // authentication completed (anonymously or with account)
    // Attention: should never be false after onboarding, since we cannot persist any data without a user
    public static var hasUser: Bool {
        currentUser != nil
    }
    
    // documentId of currents user collection (anonymouly or with account)
    // Attention: should never be nil after onboarding, since we cannot persist any data without it
    public static var userId: String? {
        currentUser?.uid
    }
    
    // user is signed in with user account
    public static var userIsAuthenticated: Bool {
        !(currentUser?.isAnonymous ?? true)
    }
    
        
    
    
    // TODO
    func createDevUser(completion: @escaping ((String, String) -> Void)) {
        // login with email<
        completion("abc@dev.de", "uid123")
    }
    
    func login() {
        #if DEBUG
        
        // set auth
        #endif
        
    }
    
    
    public static func authenticateAnonymously(completion: @escaping(Error?) -> Void) {
        guard !hasUser else {
            // user is already authenticated
            completion(nil)
            return
        }
        
        auth.signInAnonymously { _, error in
            completion(error)
        }
    }
}
