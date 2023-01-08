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
     
     The providerId is checked because if there is none, the user is either not signed in or is anonymous.
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
     Delete the users account in Firebase
     To simplify error handling, let the user authenticate before accessing this function.
     
     Database Triggers need to be implemented to remove all associated data.
     */
    public static func deleteAccount(completion: @escaping(Error?) -> Void) {
        guard let currentUser = auth.currentUser else {
            completion(nil)
            return
        }
        
        currentUser.delete { error in
            if let error {
                handleError(error, completion: completion)
                return
            }
            
            removeAuthorizationKey()
            completion(nil)
        }
    }
}
