//
//  Lifecycle.swift
//  
//
//  Created by Anna Münster on 22.09.22.
//

import Foundation

extension AuthenticationManager {
    /**
     Sign out from Firebase on the device and remove the authorization key for sign in with Apple.
     */
    public static func signOut(completion: @escaping (Error?) -> Void) {
        guard let providerId = auth.currentUser?.providerData.first?.providerID,
              self.providerId == providerId
        else {
            completion(AuthorizationError.providerId)
            return
        }
        
        do {
            try auth.signOut()
            removeAuthorizationKey()
            completion(nil)
        } catch let signOutError {
            handleError(signOutError, completion: completion)
        }
    }
    
    /**
     Reauthenticate User and delete its account in Firebase
     */
    public static func deleteAccount(completion: @escaping(Error?) -> Void) {
        guard let currentUser = auth.currentUser else { completion(nil); return }
        reauthenticateUser()
        
        currentUser.delete { error in
            if let error = error {
                handleError(error, completion: completion)
            } else {
                completion(nil)
            }
        }
    }
}
