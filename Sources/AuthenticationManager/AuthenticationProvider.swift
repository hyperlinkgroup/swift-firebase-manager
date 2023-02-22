//
//  AuthenticationProvider.swift
//  
//
//  Created by Anna Münster on 20.01.23.
//

import Foundation

public enum AuthenticationProvider: String {
    case signInWithApple, emailPassword, anonymous
}

extension AuthenticationManager {
    /**
     - Returns: If the user is currently authenticated, the current AuthenticationProvider is returned that the user used to sign in
     */
    static var currentProvider: AuthenticationProvider? {
        get {
            guard let value = UserDefaults.standard.string(forKey: UserDefaultsKeys.authenticationProvider.rawValue) else {
                self.setDefaultProviderKey()
                return self.currentProvider
            }
            return AuthenticationProvider(rawValue: value)
        }
        set {
            let value = newValue?.rawValue ?? ""
            UserDefaults.standard.set(value, forKey: UserDefaultsKeys.authenticationProvider.rawValue)
        }
    }
    
    
    /**
     If a user is already signed in but the provider key is missing (e.g. because of earlier version), we need to deduct the provider by checking the login methods
     */
    private static func setDefaultProviderKey() {
        guard hasUser else {
            currentProvider = nil
            return
        }
         
        if userIsAuthenticated {
            if authorizationKey != nil {
                currentProvider = .signInWithApple
            } else {
                currentProvider = .emailPassword
            }
        } else {
            currentProvider = .anonymous
        }
    }
}
