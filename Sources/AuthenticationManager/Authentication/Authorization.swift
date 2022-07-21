//
//  Authorization.swift
//  
//
//  Created by Kevin Waltz on 22.04.22.
//

import Foundation
import AuthenticationServices

extension AuthenticationManager {
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
    static func checkAuthorizationState(completion: @escaping (Bool, Error?) -> Void) {
        guard let authorizationKey = authorizationKey else {
            completion(false, nil)
            return
        }
        
        ASAuthorizationAppleIDProvider().getCredentialState(forUserID: authorizationKey) { credentialState, error in
            switch credentialState {
            case .authorized:
                completion(true, error)
            case .notFound, .transferred, .revoked:
                completion(false, error)
            @unknown default:
                completion(false, error)
            }
        }
    }
}
