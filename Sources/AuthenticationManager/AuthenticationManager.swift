//
//  AuthenticationManager.swift
//  
//
//  Created by Anna Münster on 22.04.22.
//

import FirebaseAuth

open class AuthenticationManager: NSObject {
    static let auth = Auth.auth()
    static let providerId = "apple.com"
    
    static var configuration = Configuration()
    static var currentNonce = Nonce()
    
    /**
        Possibility to change custom settings. Not needed if standard settings are used.
     */
    public static func setup(_ config: Configuration) {
        self.configuration = config
    }
}

// MARK: - Auth Getter

extension AuthenticationManager {
    static var currentUser: User? {
        auth.currentUser
    }
    
    /**
    - Returns: `true` if a user is authenticated
     */
    public static var hasUser: Bool {
        currentUser != nil
    }
    
    /**
     - Returns: ID of the currently authenticated user or `nil` if the user is unauthenticated
     */
    public static var userId: String? {
        currentUser?.uid
    }
    
    /**
     - Returns: `true` if user is authenticated and not anonymous
     */
    public static var userIsAuthenticated: Bool {
        !(currentUser?.isAnonymous ?? true)
    }
}

// MARK: - User Getter

extension AuthenticationManager {
    
    enum UserDefaultsKeys: String {
        case authorizationIdKey,
             authenticationProvider,
             userNameKey,
             emailKey
    }
    
    /**
     - Returns: Concatenated name ("John Doe", "John" or "Doe") if user provided details during Sign In with Apple or was set manually
     */
    public static var userName: String? {
        get { UserDefaults.standard.string(forKey: UserDefaultsKeys.userNameKey.rawValue) }
        set { UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.userNameKey.rawValue) }
    }
    
    /**
     - Returns: Email Address if user provided details during Sign In with Apple or was set manually
     */
    public static var email: String? {
        get { UserDefaults.standard.string(forKey: UserDefaultsKeys.emailKey.rawValue) }
        set { UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.emailKey.rawValue) }
    }
}
