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
    public static var authorizationKey: String? {
        get { UserDefaults.standard.string(forKey: authorizationIdKey) }
        set { UserDefaults.standard.set(newValue, forKey: authorizationIdKey) }
    }
    
    public static func removeAuthorizationKey() {
        UserDefaults.standard.set(nil, forKey: authorizationIdKey)
    }
    
    
    /**
     Check whether the user authorized the app to send push notifications.
     
     This cannot be used to ask for permission. It is solely to check for the permission status.
     */
    static func checkAuthorizationState(completion: @escaping (Result<Void, AuthorizationError>) -> Void) {
        guard let authorizationKey = authorizationKey else {
            completion(.failure(.credentialState(description: "Missing Key from User Defaults", error: nil)))
            return
        }
        
        ASAuthorizationAppleIDProvider().getCredentialState(forUserID: authorizationKey) { credentialState, error in
            switch credentialState {
            case .authorized:
                completion(.success)
            default:
                completion(.failure(.credentialState(description: credentialState.description, error: error)))
            }
        }
    }
}

enum AuthorizationError: LocalizedError {
    case credentialState(description: String, error: Error?)
}

extension ASAuthorizationAppleIDProvider.CredentialState {
    var description: String {
        switch self {
        case .revoked: return "The user’s authorization has been revoked and they should be signed out."
        case .authorized: return "The user is authorized."
        case .notFound: return "The user hasn’t established a relationship with Sign in with Apple."
        case .transferred: return "The app has been transferred to a different team, and the user’s identifier needs to be migrated."
        @unknown default: return "Unknown CredentialState"
        }
    }
}
