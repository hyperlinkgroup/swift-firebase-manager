//
//  AuthenticationManager.swift
//  
//
//  Created by Anna Münster on 22.04.22.
//

import FirebaseAuth

public enum AuthenticationProvider {
    case signInWithApple, emailPassword, anonymous
}

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
    
    public static var currentUser: User? {
        auth.currentUser
    }
    
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
}

// MARK: - User Getter

extension AuthenticationManager {
    
    enum UserDefaultsKeys: String {
        case authorizationIdKey, userNameKey, emailKey
    }
    
    public static var userName: String? {
        get { UserDefaults.standard.string(forKey: UserDefaultsKeys.userNameKey.rawValue) }
        set { UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.userNameKey.rawValue) }
    }
    
    public static var email: String? {
        get { UserDefaults.standard.string(forKey: UserDefaultsKeys.emailKey.rawValue) }
        set { UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.emailKey.rawValue) }
    }
}
