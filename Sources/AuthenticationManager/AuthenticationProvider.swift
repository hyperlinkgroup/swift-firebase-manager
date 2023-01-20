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
            guard let value = UserDefaults.standard.string(forKey: UserDefaultsKeys.authenticationProvider.rawValue) else { return nil }
            return AuthenticationProvider(rawValue: value)
        }
        set { UserDefaults.standard.set(newValue?.rawValue, forKey: UserDefaultsKeys.authenticationProvider.rawValue) }
    }
}
