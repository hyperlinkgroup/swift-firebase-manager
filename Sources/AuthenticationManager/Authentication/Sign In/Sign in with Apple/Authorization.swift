//
//  Authorization.swift
//  
//
//  Created by Kevin Waltz on 22.04.22.
//

import Foundation
import AuthenticationServices

extension AuthenticationManager {
    // identifier from apple credentials - used for checking authorization state after login
    static var authorizationKey: String? {
        get { UserDefaults.standard.string(forKey: UserDefaultsKeys.authorizationIdKey.rawValue) }
        set { UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.authorizationIdKey.rawValue) }
    }
    
    static func removeAuthorizationKey() {
        UserDefaults.standard.set(nil, forKey: UserDefaultsKeys.authorizationIdKey.rawValue)
    }
    
    
    /**
     Check whether the user authorized the app to use SignInWithApple.
     
     This cannot be used to ask for permission. It is solely to check for the permission status.
     */
    public static func checkAuthorizationState(completion: @escaping (Result<Bool?, Error>) -> Void) {
        guard let authorizationKey = authorizationKey, !authorizationKey.isEmpty else {
            completion(.failure(AuthorizationError.credentialState(description: "Missing Key from User Defaults", error: nil)))
            return
        }
        
        ASAuthorizationAppleIDProvider().getCredentialState(forUserID: authorizationKey) { credentialState, error in
            switch credentialState {
            case .authorized:
                completion(.success(nil))
            default:
                completion(.failure(AuthorizationError.credentialState(description: credentialState.description, error: error)))
            }
        }
    }
}
